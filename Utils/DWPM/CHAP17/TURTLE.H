/* TURTLE.H
   See TURTLE.C for instructions */

#include "pgraph.h"
typedef  unsigned long ulong;
typedef  unsigned int uint;

/* Size of text screen */
#define TEXT_SIZE 4000

/* graphics buffer */
#define SCREEN_SIZE 64000   /* 320 X 200 */
extern char far _gbuf[SCREEN_SIZE];

/* Application data (passed to XCI commands) */
struct  udata
  {
  char *gbuf;               /* pointer to graphics buffer */
  char tbuf[4000];          /* text buffer */
  char *gptr;               /* pointer to graphics screen */
  char *tptr;               /* pointer to text screen */
  struct xycoord graphxy;   /* x,y of graphic screen */
  struct rccoord textxy;    /* x,y of text screen */
  int color;                /* color */
  long backcolor;           /* background color */
/* store[10] & store[11] are for internal use */
  char *store[12];          /* screen storage */
  unsigned int pendown:1;   /* draw or move */
/* if 1, don't exit graphic mode */
  unsigned int textgraph:1;
  int heading;              /* turtle heading */

/* X and Y are stored as reals too to combat
  rounding errors */
  double realx;
  double realy;
/* 26 variables A-Z */
  long vars[26];
/* text color */
  int tcolor;
  };

/* Application data structure */
extern struct udata appdata;

int evalexpr(char *);
void turtleprompt(char *);
int _far _loadds _export getval(char *,int,
                            int,int,int *);
