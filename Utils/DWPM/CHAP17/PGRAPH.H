/* PGRAPH.H  -- Portable graphics header for TURTLE.EXE
   See MAKEFILE for instructions

*/

#ifndef PGRAPH_H
#define PGRAPH_H 1

#ifndef __BORLANDC__
/* Microsoft -- easy case use native graphics */
#include <graph.h>
#else

/* Emulation of useful stuff from graph.h */
#define _DEFAULTMODE   3
#define _TEXTC80       3
#define _MRES256COLOR 19
#define _GCLEARSCREEN 0
/* We don't really use pages */
#define _setactivepage(x)
#define _setvisualpage(x)

struct xycoord
  {
  short xcoord;
  short ycoord;
  };

struct rccoord
  {
  short row;
  short col;
  };


void _setvideomode(int);
void _clearscreen(int);
void _setcolor(int);
unsigned long _remappalette(int,unsigned long);
void _setbkcolor(unsigned long);
void _moveto(int,int);
void _settextcolor(int);
void _settextposition(int,int);
void _outtext(char *);
void _plot(int ,int);
void _lineto(int,int);
struct xycoord _getcurrentposition(void);
/* unimplemented */
void _floodfill(int,int,int);

#endif /* Borland definitions */

#endif /* Header */

