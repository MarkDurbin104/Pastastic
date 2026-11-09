/* TCMDS.C      XCI commands for TURTLE.EXE
   See MAKEFILE for instructions

*/

#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <dos.h>
#include <conio.h>
#include <string.h>
#include "pgraph.h"
#include <ctype.h>
#include <direct.h>
#define INCL_DOSPROCESS
/* 286 DOS Extender header */
#include <phapi.h>
#include <math.h>
#include <float.h>

#include "turtle.h"
#include "xci.h"

extern XCICMD gotofunc();

/* tokens for commands */
char *tokens[10];

#define NOARG if (parse(cmds)!=0) synerr;
#define synerr { _synerr(); return; }

/* syntax error */
void _synerr(void)
  {
  printf("Syntax error\n");
  }

/* parse a command line into the tokens array
   return the number of tokens */
int parse(char *cmd)
  {
  int i;
  char *t;
  t=tokens[i=0]=strtok(cmd," \t\n");
  while (t&&i<9)
    {
    t=strtok(NULL," \t\n");
    if (t)
      {
      if (i==9) return -1;
      tokens[++i]=t;
      }
    }
  return tokens[0]?i+1:0;
  }



/* Get a number from token. It must be between lo and hi
   (unless lo==hi) if it is preceeded by a + or a -, it
   is added to rel the final value is stored in *val)
   returns 1 if out of range, 0 if OK */
int _far _loadds _export getval(char *token,int rel,
                                int lo, int hi,int *val)
  {
  int flag=0;    /* add value to rel? */
  if (*token=='+') flag=1;
  if (*token=='-') flag=-1;
  if (flag) token++;

/* evaluate expression */
  *val=evalexpr(token);

/* adjust value relative */
  if (flag==-1) *val=-*val;
  if (flag) *val+=rel;

/* check range */
  if (lo!=hi&&(*val<lo||*val>hi))
    {
    printf("Bad value: %d. Use %d to %d\n",*val,lo,hi);
    return 1;
    }
  return 0;
  }

/* Get xcoordinate */
#define getxco(token,val) \
   getval(token,appdata.graphxy.xcoord,-999,999,val)

/* Get y coordinate */
#define getyco(token,val) \
   getval(token,appdata.graphxy.ycoord,-999,999,val)

/* get heading */
#define gethead(token,val) \
   (getval(token,appdata.heading,0,0,val)%360)

/* get color value */
#define getcolor(token,val) \
   getval(token,appdata.color,0,255,val)


/* run a DOS command without XCI interfering with ^C */
static void rundos(char *line)
   {
   int brkstatus=xci_defaultbrk;
   xci_defaultbrk=0;
   if (system(line)==-1)
      {
      printf("Can't execute: %s\n",line);
      }
   xci_defaultbrk=brkstatus;
   }



/* EDIT file */
XCICMD editcmd(int cmd, char far *cmds,struct udata *data)
  {
  char cmdline[129];
  char *cmdst;
  unsigned long stat;
  if (cmd)
    {
    printf("Edit a file\n");
    return;
    }
/* Get editor name from $TURTLEEDIT */
  cmdst=getenv("TURTLEEDIT");
/* If not specified, use DOS 5 EDIT command */
  if (!cmdst) cmdst="EDIT";
/* build command line */
  strcpy(cmdline,cmdst);
  strcat(cmdline," ");
  strcat(cmdline,cmds);
  rundos(cmdline);
  }


/* DOS directory */
XCICMD dircmd(int cmd, char far *cmds,struct udata *data)
  {
  char cmdline[129];
  unsigned long stat;
  if (cmd)
    {
    printf("DOS directory\n");
    return;
    }
  strcpy(cmdline,"DIR ");
  strcat(cmdline,cmds);
  rundos(cmdline);
  }


/* DOS command */
XCICMD doscmd(int cmd, char far *cmds,struct udata *data)
  {
  char cmdline[129];
  char *cmdst;
  int rc;
  unsigned long stat;
  if (cmd)
    {
    printf("Run DOS or a DOS command\n");
    return;
    }
  rundos(*cmds?cmds:"COMMAND");  /* quick, yet dirty */
  }

/* change directory */
XCICMD cdcmd(int cmd, char far *cmds,struct udata *data)
  {
  int buf;
  if (cmd)
    {
    printf("Change the current working directory\n");
    return;
    }
  if (chdir(cmds))
     printf("Error changing directory\n");
  }


/* Get text xy coordinate */
struct rccoord getxy(void)
  {
  struct rccoord rc;
  union REGS r;
  r.h.ah=3;
  r.h.bh=0;
  int86(0x10,&r,&r);
  rc.row=r.h.dh;
  rc.col=r.h.dl;
  return rc;
  }

/* move text cursor to x,y */
goto_xy(short x,short y)
  {
  union REGS r;
  r.h.ah=2;
  r.h.bh=0;
  r.h.dh=y;
  r.h.dl=x;
  int86(0x10,&r,&r);
  }


/* Initilize pointers */
setptr(struct udata *data)
  {
  unsigned int rseg;

/* buffer 10 stores pointer to graphics buffer */
  data->store[10]=data->gbuf=_gbuf;

/* Get PM pointer to VGA screen */
  DosMapRealSeg(0xa000,(unsigned long)SCREEN_SIZE,(PSEL)&rseg);
/* buffer 11 points to screen */
  data->store[11]=data->gptr=MAKEP(rseg,0);

/* Get PM pointer to text screen */
  DosMapRealSeg(0xb800,TEXT_SIZE,(PSEL)&rseg);
  data->tptr=MAKEP(rseg,0);
  }


/* switch mode to graphics */
void gograph(struct udata *data)
  {
/* Init if required */
  if (!data->gptr) setptr(data);
/* if already in graphics, quit */
  if (data->textgraph) return;
/* save text screen */
  memcpy(data->tbuf,data->tptr,TEXT_SIZE);
/* save cursor position */
  data->textxy=getxy();

/* switch modes */
  _setvideomode(_MRES256COLOR);
/* set colors */
  _setcolor(data->color);
  _setbkcolor(data->backcolor);
/* restore graphics position */
  _moveto(data->graphxy.xcoord,data->graphxy.ycoord);
/* restore contents of buffer */
  memcpy(data->gptr,data->gbuf,(unsigned)SCREEN_SIZE);
  }


/* Switch to text mode */
void gotext(struct udata *data)
  {
/* INIT if required */
  if (!data->gptr) setptr(data);
/* If already in text mode quit */
  if (data->textgraph) return;
/* store graphics screen */
  memcpy(data->gbuf,data->gptr,(unsigned)SCREEN_SIZE);
/* save position */
  data->graphxy=_getcurrentposition();

/* switch to text mode */
  _setvideomode(_TEXTC80);
/* restore text screen */
  memcpy(data->tptr,data->tbuf,TEXT_SIZE);
/* restore text cursor */
  goto_xy(data->textxy.col,data->textxy.row);
  }


/* move turtle to x,y */
turmove(int x,int y)
  {
/* Since this function is built in, its OK to use appdata
   directly. A DLL command would need the pointer passed
   to it by XCI */
/* Draw or move based on mode */
  if (appdata.pendown)
    _lineto(x,y);
  else
    _moveto(x,y);
  }

/* Show graphics screen */
XCICMD showcmd(int cmd, char far *cmds,struct udata *data)
  {
  int n;
  if (cmd)
    {
    printf("Show graphics screen\n");
    return;
    }
  n=parse(cmds);
  if (n>1)
    synerr;
  if (!n)
    {
    gograph(data);
    if (!getch()) getch();
    gotext(data);
    return;
    }
  if (!stricmp(tokens[0],"ON"))
      {
      if (!data->textgraph)
        {
        gograph(data);
        data->textgraph=1;
        }
      return;
      }
  if (!stricmp(tokens[0],"OFF"))
      {
      if (data->textgraph)
        {
        data->textgraph=0;
        gotext(data);
        }
      return;
      }
    synerr;
  }


/* SETX */
XCICMD setxcmd(int cmd, char far *cmds,struct udata *data)
  {
  int newx;
  if (cmd)
    {
    printf("Set X coordinate\n");
    return;
    }
  if (parse(cmds)!=1) synerr;
  if (getxco(tokens[0],&newx)) return;
  gograph(data);
  turmove(data->graphxy.xcoord=newx,data->graphxy.ycoord);
  data->realx=(double)newx;
  gotext(data);
  }

/* SETY */
XCICMD setycmd(int cmd, char far *cmds,struct udata *data)
  {
  int newy;
  if (cmd)
    {
    printf("Set Y coordinate\n");
    return;
    }
  if (parse(cmds)!=1) synerr;
  if (getyco(tokens[0],&newy)) return;
  gograph(data);
  data->realy=(double)newy;
  turmove(data->graphxy.xcoord,data->graphxy.ycoord=newy);
  gotext(data);
  }


/* SET both X and Y */
XCICMD setxycmd(int cmd, char far *cmds,struct udata *data)
  {
  int newx,newy;
  if (cmd)
    {
    printf("Set X & Y coordinates\n");
    return;
    }
  if (parse(cmds)!=2) synerr;
  if (getxco(tokens[0],&newx) || getyco(tokens[1],&newy))
     return;
  gograph(data);
  data->realx=(double)newx;
  data->realy=(double)newy;
  turmove(data->graphxy.xcoord=newx,
          data->graphxy.ycoord=newy);
  gotext(data);
  }


/* Set color */
XCICMD colorcmd(int cmd, char far *cmds,struct udata *data)
  {
  int col;
  if (cmd)
    {
    printf("Set color\n");
    return;
    }
  if (parse(cmds)!=1) synerr;
  if (getcolor(tokens[0],&col)) return;
  gograph(data);
  data->color=col;
  _setcolor(col);
  gotext(data);
  }



/* Clear screen */
XCICMD clearcmd(int cmd, char far *cmds,struct udata *data)
  {
  if (cmd)
    {
    printf("Clear the screen\n");
    return;
    }
    NOARG;
  gograph(data);
  _moveto(0,0);
  _clearscreen(_GCLEARSCREEN);
  data->heading=0;
  data->graphxy.xcoord=data->graphxy.ycoord=0;
  data->realx=data->realy=0.0;
  gotext(data);
  }

/* pen up (change mode) */
XCICMD penupcmd(int cmd, char far *cmds,struct udata *data)
  {
  if (cmd)
    {
    printf("Cause the turtle not to draw\n");
    return;
    }
  NOARG;
  data->pendown=0;
  }

/* pen down (change mode) */
XCICMD pendowncmd(int cmd, char far *cmds,
                  struct udata *data)
  {
  if (cmd)
    {
    printf("Cause the turtle to draw\n");
    return;
    }
  NOARG;
  data->pendown=1;
  }

/* change background color */
XCICMD backgcmd(int cmd, char far *cmds,struct udata *data)
  {
  long col;
  int index;
  if (cmd)
    {
    printf("Set the background color\n");
    return;
    }
  if (parse(cmds)!=1) synerr;
  getcolor(tokens[0],&index);
  gograph(data);
  col=_remappalette(index,0L);
  _remappalette(index,col);
  data->backcolor=col;
  _setbkcolor(col);
  gotext(data);
  }


/* Set cursor to 0,0 */
XCICMD homecmd(int cmd, char far *cmds,struct udata *data)
  {
  char cmdline[10];
  if (cmd)
    {
    printf("Move the turtle to the top left corner\n");
    return;
    }
  NOARG;
  strcpy(cmdline,"0 0\n");
  data->heading=0;
/* simulate XCI command */
/* NOTE: you shouldn't use a string constant (e.g.:
   setxycmd(0,"0 0\n",data))
   the parse algorithm will chop up the string constant
   the first time you call it which will cause a syntax
   error on subsequent calls. */
  setxycmd(0,cmdline,data);
  }

/* Turn heading */
XCICMD turncmd(int cmd, char far *cmds,struct udata *data)
  {
  int turn;
  if (cmd)
    {
    printf("Turn the turtle\n");
    return;
    }
  if (parse(cmds)!=1) synerr;
  if (gethead(tokens[0],&turn)) return;
  data->heading=turn;
  }

#define PI ((double)3.1415926536)
/* convert degrees to radians */
#define deg2rad(deg) (((double) deg)*(PI/180.0))
/* quick signum function */
#define SGN(a) ((a)<0?-1:(a)>0?1:0)

/* move turtle ahead */
XCICMD movecmd(int cmd, char far *cmds,struct udata *data)
  {
  int amt,x1,y1;
  double rads,tempreal;
  if (cmd)
    {
    printf("Move the turtle\n");
    return;
    }
  if (parse(cmds)!=1) synerr;
  getval(tokens[0],0,0,0,&amt);
  if (!amt) return;
/* Get heading in radians */
  rads=deg2rad(data->heading);

/* calculate new X & Y
   (cos=x/r    sin=y/r) */
  data->realx+=amt*cos(rads);
  x1=(int)(data->realx+.5*SGN(data->realx));
  data->realy+=amt*sin(rads);
  y1=(int)(data->realy+.5*SGN(data->realy));
  gograph(data);
  turmove(data->graphxy.xcoord=x1,data->graphxy.ycoord=y1);
  gotext(data);
  }


/* repeat a command file */
XCICMD rptcmd(int cmd, char far *cmds,struct udata *data)
  {
  int count;
  char fn[67];
  if (cmd)
    {
    printf("Repeat a command file\n");
    return;
    }
  if (parse(cmds)!=2) synerr;
  getval(tokens[0],0,0,0,&count);
  if (count<=0)
    {
    printf("Error: count must be >=0\n");
    return;
    }
  strcpy(fn,tokens[1]);
  while (count--) dofunc(0,fn,data);
  }


/* delay a specified number of .1 seconds */
XCICMD delaycmd(int cmd, char far *cmds,struct udata *data)
  {
  int amt;
  unsigned long t;
  REGS16 r;
  if (cmd)
    {
    printf("Delay for a time (in .1 second increments)\n");
    return;
    }
  if (parse(cmds)!=1) synerr;
  getval(tokens[0],0,0,0,&amt);
  if (amt<0)
    {
    amt=0;
    printf("Error: delay time must be >0\n");
    }
  if (!amt) return;
  t=amt*100000L;
  r.ax=0x8600;
  r.cx=(t&0xFFFF0000)>>16;
  r.dx=t&0xffff;

/* Use INT 15H Function 86H to delay -- DOS extender doesn't
  support this directly. We must use DosRealIntr() */
  DosRealIntr(0x15,&r,0L,0);
  }



/* If command */
/* Use XCI do and goto commands to perform do and goto */
XCICMD ifcmd(int cmd, char far *cmds,struct udata *data)
  {
  int bool;
  char fn[67];
  if (cmd)
    {
    printf("Conditionally execute a commmand file\n");
    return;
    }
  if (parse(cmds)!=3) synerr;
  if (getval(tokens[0],0,0,0,&bool)) return;
  if (bool)
    {
    if (!stricmp(tokens[1],"THEN")&&
        !stricmp(tokens[2],"EXIT"))
      {
/* goto EOF of current file -- XCI thinks it is done */
      fseek(xci_infile,0L,SEEK_END);
      return;
      }
    if (!stricmp(tokens[1],"DO"))
      {
      strcpy(fn,tokens[2]);
      dofunc(0,fn,data);
      return;
      }
    if (!stricmp(tokens[1],"GOTO"))
      {
      gotofunc(0,tokens[2],data);
      return;
      }
    synerr;
    }
  }


/* Set a variable */
XCICMD setcmd(int cmd, char far *cmds,struct udata *data)
  {
  int val;
  if (cmd)
    {
    printf("Set a variable\n");
    return;
    }
  if (parse(cmds)!=2) synerr;
  if (strlen(tokens[0])!=1||!isalpha(*tokens[0]))
    {
    printf("Variables must be A-Z\n");
    return;
    }
  getval(tokens[1],0,0,0,&val);
  data->vars[toupper(*tokens[0])-'A']=val;
  }

/* Stack for PUSH/POP commands */
static int intstack[512];
static int intstackp=0;

XCICMD pushcmd(int cmd, char far *cmds,struct udata *data)
  {
  int val;
  if (cmd)
    {
    printf("Push a value on the stack\n");
    return;
    }
  if (parse(cmds)!=1) synerr;
  getval(tokens[0],0,0,0,&val);
  if (intstackp==sizeof(intstack)/sizeof(int))
    printf("Stack overflow\n");
  else
    intstack[intstackp++]=val;
  }


XCICMD popcmd(int cmd, char far *cmds,struct udata *data)
  {
  int val;
  if (cmd)
    {
    printf("Pop the top of the stack to a variable\n");
    return;
    }
  if (parse(cmds)!=1) synerr;
  if (strlen(tokens[0])!=1||!isalpha(*tokens[0]))
    {
    printf("Variables must be A-Z\n");
    return;
    }
  if (!intstackp)
    printf("Nothing to pop\n");
  else
    data->vars[toupper(*tokens[0])-'A']=
                  intstack[--intstackp];
  }



/* Store the graphics screen to a buffer */
XCICMD stocmd(int cmd, char far *cmds,struct udata *data)
  {
  int buf;
  if (cmd)
    {
    printf("Store the screen to memory\n");
    return;
    }
  if (parse(cmds)!=1) synerr;
  if (getval(tokens[0],0,1,10,&buf)) return;
  if (!data->store[--buf])
     {
/* allocate storage if needed */
     data->store[buf]=malloc((unsigned)SCREEN_SIZE);
     if (!data->store[buf])
        {
        printf("Out of memory\n");
        return;
        }
      }
/* copy to the screen if in graphics mode, or to graphics
   buffer if not */
  memcpy(data->store[buf],data->store[10+data->textgraph],
         (unsigned)SCREEN_SIZE);
  }


/* Restore a buffer to the screen */
XCICMD rclcmd(int cmd, char far *cmds,struct udata *data)
  {
  int buf;
  if (cmd)
    {
    printf("Recall a screen from memory\n");
    return;
    }
  if (parse(cmds)!=1) synerr;
  if (getval(tokens[0],0,1,10,&buf)) return;
  if (!data->store[--buf])
     {
     printf("Buffer %d empty\n",buf+1);
     return;
     }
  memcpy(data->store[10+data->textgraph],data->store[buf],
         (unsigned)SCREEN_SIZE);
  }


/* Fill a region */
XCICMD fillcmd(int cmd, char far *cmds,struct udata *data)
  {
  int buf;
#ifdef __BORLANDC__
  printf("fill is only supported with the Microsoft "
         "graphics library\n");
  return;
#else
  if (cmd)
    {
    printf("Fill a region\n");
    return;
    }
  NOARG;
  gograph(data);
  _floodfill(data->graphxy.xcoord,data->graphxy.ycoord,
             data->color);
  gotext(data);
#endif
  }


/* Write text */
XCICMD textcmd(int cmd, char far *cmds,struct udata *data)
  {
  int buf;
  if (cmd)
    {
    printf("Print text\n");
    return;
    }
  gograph(data);
  _settextcolor(data->tcolor);
/* calculate text cursor based on graphics cursor */
  _settextposition(data->graphxy.xcoord/8,
                   data->graphxy.ycoord/8);
  _outtext(cmds);
  gotext(data);
  }

/* prompt user with string */
/* if string starts with ~ then don't add a new line */
XCICMD promptcmd(int cmd, char far *cmds,struct udata *data)
  {
  int buf;
  if (cmd||!*cmds)
    {
    printf("Prompt user\n");
    return;
    }
  turtleprompt(cmds+(*cmds=='~'));
  if (*cmds!='~') turtleprompt("\n");
  }



/* Set text color */
XCICMD textccmd(int cmd, char far *cmds,struct udata *data)
  {
  int col;
  if (cmd)
    {
    printf("Set text color\n");
    return;
    }
  if (parse(cmds)!=1) synerr;
  if (getval(tokens[0],data->tcolor,0,15,&col)) return;
  data->tcolor=col;
  }



/* Install commands. This is called by the XCI startup
   function in TURTLE.C. It is in this file so TURTLE.C
   doesn't need prototypes for each command function */
int installcmds()
  {
/* enable XCI's internal goto command */
  if (addcmd("goto",gotofunc)) return 1;
  if (addcmd("cd",cdcmd)) return 1;
  if (addcmd("dir",dircmd)) return 1;
  if (addcmd("dos",doscmd)) return 1;
  if (addcmd("edit",editcmd)) return 1;
  if (addcmd("repeat",rptcmd)) return 1;
  if (addcmd("if",ifcmd)) return 1;
  if (addcmd("set",setcmd)) return 1;
  if (addcmd("sto",stocmd)) return 1;
  if (addcmd("rcl",rclcmd)) return 1;
  if (addcmd("push",pushcmd)) return 1;
  if (addcmd("pop",popcmd)) return 1;
  if (addcmd("delay",delaycmd)) return 1;
  if (addcmd("prompt",promptcmd)) return 1;
  if (addcmd("show",showcmd)) return 1;
  if (addcmd("fill",fillcmd)) return 1;
  if (addcmd("textcolor",textccmd)) return 1;
  if (addcmd("text",textcmd)) return 1;
  if (addcmd("setx",setxcmd)) return 1;
  if (addcmd("sety",setycmd)) return 1;
  if (addcmd("setxy",setxycmd)) return 1;
  if (addcmd("background",backgcmd)) return 1;
  if (addcmd("pencolor",colorcmd)) return 1;
  if (addcmd("clear",clearcmd)) return 1;
  if (addcmd("home",homecmd)) return 1;
  if (addcmd("penup",penupcmd)) return 1;
  if (addcmd("pendown",pendowncmd)) return 1;
  if (addcmd("turn",turncmd)) return 1;
  if (addcmd("move",movecmd)) return 1;
  if (addcmd("forward",movecmd)) return 1;
  return 0;
  }
