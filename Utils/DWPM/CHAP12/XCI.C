/* XCI.C     An extensible command interpreter for the
   Phar Lap 286 DOS Extender
   See MAKEFILE for compile information
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include <dos.h>
#include <phapi.h>
#include <setjmp.h>
#include <conio.h>
#include "xci.h"

#ifdef __BORLANDC__
#define INT_REGS REGS_BINT
#else
#define INT_REGS REGS16
#endif

/* Mask for Zero flag (used by keyboard routines */
#define Z_FLAG 0x40

static int adddll(char *);
static int findcmd(char *);

/* Table of commands (dynamically allocated) */
static struct cmdtbl
  {
  char far *cmd;
  XCICMDP f;
  } *cmds=NULL;

/* Number of commands in table */
static unsigned int nrcmds=0;

/* Case sensitive? */
static int truecase=0;

/* secret dummy definition for udata */
struct udata
  {
  int unknown;
  };

/* default hook function prototypes */
void xci_prompter();     /* func to prompt */
char *xci_input();       /* func to get input */
void xci_preposthelp();  /* pre & post help command */

/* default prompt string -- can be changed by client */
char *xci_prompt="? ";

/* default routines -- can be changed by client */
void (*xcif_prompt)()=xci_prompter;
void (*xcif_prehelp)()=xci_preposthelp;
void (*xcif_posthelp)()=xci_preposthelp;
char *(*xcif_input)()=xci_input;

/* flag set when break detected */
static int broke;

/* Jump to top level command loop */
jmp_buf cmdloop;


/* default command function prototypes */
XCICMD dofunc(int cmd,char *s,struct udata *data);
XCICMD linkfunc(int cmd,char *s,struct udata *data);
XCICMD quitfunc(int cmd,char *s,struct udata *data);
XCICMD helpfunc(int cmd,char *s,struct udata *data);

/* default commands
  although GOTO is a built-in command, the client program
  must explicitly enable it if it wants to use it */
static char *defcmd[]= { "quit", "help", "link", "do" };

/* addresses of default commands */
static XCICMDP deffunc[]={
                          (XCICMDP)quitfunc,
                          (XCICMDP)helpfunc,
                          (XCICMDP)linkfunc,
                          (XCICMDP)dofunc
                         };

/* non-zero if running a script via DO */
static int interactive=0;

/* stack of file positions for nested DO commands */
/* Files are closed and reopened to avoid DOS file limit */
static struct fstack
       {
       char *fp;             /* file name */
       long pos;             /* position in file */
       struct fstack * next; /* next fstack record */
       } *instack;


/* default stdin handle */
static FILE *baseio;

/* Current input file */
FILE *xci_infile;

/* Set to 1 when someone wants to exit */
int xci_exitflag=0;

/* Default break action */
int xci_defaultbrk=1;

/* Break vectors */
PIHANDLER oldbreak;  /* PIHANDLER=Prot. Int. Handler */
REALPTR oldbreal; /* REALPTR=Pointer to real mode address */
PIHANDLER old1b;
REALPTR old1breal;

/* Bios segment (you can't call DosGetBIOSseg from ISR) */
USHORT biosseg;

/* ^Break handlers */
void _interrupt _far xci_int1b(INT_REGS r)
  {
  union REGS rr;
  unsigned int *keyhead,*keytail;

/* Borland doesn't clear CLD */
#ifdef __BORLANDC
   asm cld
#endif

/* If xci_defaultbrk is clear, then we are in DOS shell
   and don't want to take any action */
  if (!xci_defaultbrk)
    {
/* Chain to old break handler (never returns) */
    DosChainToRealIntr(old1breal);
    }
  keyhead=MAKEP(biosseg,0x1A);
  keytail=MAKEP(biosseg,0x1C);
  broke=1;
/* purge keyboard buffer */
  *keyhead=*keytail;
/* push ^C at head of keyboard buffer */
#ifndef __BORLANDC__
  rr.h.ah=5;
  rr.x.cx=3;
  int86(0x16,&rr,&rr);
#else
/* Sometimes int86() does't work under Borland and Phar Lap
   in interrupt routine */
  asm {
    mov ah,5
    mov cx,3
    int 0x16
    }
#endif
  }

void _interrupt _far xci_int16(INT_REGS r)
  {
  REGS16 r1;
/* Borland doesn't clear direction flag */
#ifdef __BORLANDC
   asm cld
#endif
  unsigned ah=r.ax>>8;
  _enable();
  if (xci_defaultbrk&&(ah==0||ah==0x10||ah==1||ah==0x11))
    {
    do
      {
      r1.ax=0x100;
      r1.flags=0;
/* Simulate interrupt to old INT 16H handler */
      DosRealFarCall(oldbreal,&r1,0,-1,r1.flags);
      if ((r1.flags&Z_FLAG)&&(ah==1||ah==0x11))
        {
        r.flags=r1.flags;
        return;
        }
/* Wait for key press */
      } while (r1.flags&Z_FLAG);
/* If break character -- replace it with a carriage return */
      if ((r1.ax&0xff)==3||r1.ax==0x300)
        {
        unsigned int *keyhead;
        keyhead=MAKEP(biosseg,0x1A);
        keyhead=MAKEP(biosseg,*keyhead);
        *keyhead='\r';
        broke=1;
        }
     }
  DosChainToRealIntr(oldbreal);
  }


/* XCI Clean up */
/* Note: DosExitList requires this to be a pascal function */
void pascal far xci_clean(unsigned int reason)
  {
/* restore interrupt vectors */
   DosSetRealProtVec(0x16,oldbreak,oldbreal,NULL,NULL);
   DosSetRealProtVec(0x1b,old1b,old1breal,NULL,NULL);
/* Exit handler must call DosExitList with EXLST_EXIT
   to proceed with the termination */
   DosExitList(EXLST_EXIT,NULL);
  }



/* default functions */
void xci_prompter(char *s)
   {
   printf("%s",s);
   }

char *xci_input(char *inbuf,unsigned int siz,FILE *input)
   {
   return fgets(inbuf,siz,input);
   }

/* No pre or post help action by default */
void xci_preposthelp()
   {
   }


/* Main command routine */
/* dll is initial DLL to load
   startfile is initial file to DO
   cases is 1 if case sensitivity is required
   userfunc is pointer to user function called at
            start and end */
int command(char *dll, char *startfile, int cases,
            void far *user,XCICMDP userfunc)
  {
  int i;
  char inbuf[129],*p;
  if (!cmds)
    {
/* first time  (not done for recursive calls) */
   DosGetBIOSSeg(&biosseg);
/* Due to a 286 DOS extender bug in versions prior to 1.4,
   you must set the INT 16H ProtVec before
   using PassToProtVec... */
    DosSetProtVec(0x16,(PIHANDLER)xci_int16,&oldbreak);
    DosSetPassToProtVec(0x16,(PIHANDLER)xci_int16,NULL,
                        &oldbreal);
    DosSetPassToProtVec(0x1b,(PIHANDLER)xci_int1b,
                        &old1b,&old1breal);
/* set up exit handler */
    DosExitList(EXLST_ADD,(PFNEXITLIST)xci_clean);
    truecase=cases;
    xci_infile=stdin;

/* install default commands */
    cmds=(struct cmdtbl *)malloc(4*sizeof(struct cmdtbl));
    if (!cmds) return 1;
    nrcmds=4;
    for (i=0;i<nrcmds;i++)
      {
      cmds[i].cmd=defcmd[i];
      cmds[i].f=deffunc[i];
      }

/* load default DLL (if specified) */
    if (dll&&*dll)
      if (adddll(dll))
         printf(
           "Warning: unable to load default command DLL\n");

/* call user function */
    if (userfunc) userfunc(0,NULL,user);

/* execute default DO file */
    if (startfile&&*startfile) dofunc(0,startfile,user);

/* set jump buffer for future longjmp's --
   when longjmp() executes, control returns here */
    setjmp(cmdloop);
    }

/* initialization done -- begin main processing */
  while (1)
    {
    char *token,*tail;
/* if someone wants to quit then quit */
    if (xci_exitflag)
      {
/* call user function */
      if (userfunc) userfunc(1,NULL,user);
/* reset some things in case we are called again */
/* restore interrupt vectors */
      DosSetRealProtVec(0x16,oldbreak,oldbreal,NULL,NULL);
      DosSetRealProtVec(0x1b,old1b,old1breal,NULL,NULL);
      DosExitList(EXLST_REMOVE,(PFNEXITLIST)xci_clean);
      xci_infile=stdin;
      interactive=0;
      instack=NULL;
      free((void *)cmds);
      cmds=NULL;
      return 0;
      }

/* If interactive==0 (not script) then prompt */
    if (!interactive) (*xcif_prompt)(xci_prompt);

/* get input from user or file */
    *inbuf='\0';
/* Call input function -- can be set to different
   functions depending on client's needs */
    (*xcif_input)(inbuf,sizeof(inbuf),xci_infile);

/* If break detected then go to top level */
    if (broke)
      {
      struct fstack *f;
      broke=0;
      /* free fstack entries */
      for (f=instack;f;f=f->next) free(f->fp);
      instack=NULL;
      interactive=0;
      xci_infile=stdin;
/* Jump to setjmp() at top of command loop */
      longjmp(cmdloop,1);
      }

/* If end of do file, return. If end of console, ignore */
    if (!*inbuf&&feof(xci_infile))
      {
      if (interactive)
        {
        return 0;
        }
      clearerr(xci_infile);
      continue;
      }

/* got some input -- lets look at it */
    i=strspn(inbuf," \t");

/* skip blank lines and comments */
    if (inbuf[i]=='\n') continue;
    if (inbuf[i]=='#') continue;

/* eat off \n from line */
    p=strchr(inbuf+i,'\n');
    if (p) *p='\0';

/* get a token */
    token=strtok(inbuf+i," \t");
    if (!token) continue;  /* this should never happen */

/* do we recognize the command? (internal or from dll) */
    i=findcmd(token);
/* NO: error */
    if (i==-1)
      {
      printf("Unknown command %s\n",token);
      continue;
      }

/* YES: compute command's tail (arguments) */
    tail=token+strlen(token)+1;
    tail+=strspn(tail," \t");
/* execute command */
    cmds[i].f(0,tail,user);
    }
  }


/* Find a command -- search backwards so new commands
   replace old ones */
static int findcmd(char *s)
  {
  int i,stat;
  for (i=nrcmds-1;i>=0;i--)
    {
    if (!(truecase?
           strcmp(s,cmds[i].cmd)
           :
           stricmp(s,cmds[i].cmd)))
       return i;
    }
  return -1;
  }


/* Add a DLL to the command input table
   returns 0 if successful  */
static adddll(char *dll)
  {
  char cmdnam[33],*p;
  HMODULE h=0;
  unsigned ord=0;
  p=strrchr(dll,'\\');

/* check to see if module is already loaded */
  if (!DosGetModHandle(p?p+1:dll,&h))
    {
    printf("%s already loaded\n",p?p+1:dll);
    return 1;
    }

/* Load module if possible */
  if (DosLoadModule(0,0,dll,&h))
       return 1;

/* find all exported functions in module */
  while (!DosEnumProc(h,cmdnam,(PUSHORT)&ord))
     {
     PFN fn;
/* Get function's address */
     DosGetProcAddr(h,cmdnam,&fn);
/* add command -- skipt 1st character (it is a _) */
     if (addcmd(cmdnam+1,(XCICMDP) fn)) return 1;
     }
  return 0;
  }

/* add a command -- returns 0 for success */
#ifdef addcmd
#undef addcmd
#endif

addcmd(char *cmdnam,XCICMDP fn)
  {
  struct cmdtbl *ct;
/* make more room in table  */
  ct=(struct cmdtbl *)
      realloc(cmds,(nrcmds+1)*sizeof(struct cmdtbl));
  if (!ct) return 1;
  cmds=ct;
/* add name and function */
  cmds[nrcmds].cmd=strdup(cmdnam);
  if (!cmds[nrcmds].cmd) return 1;
  cmds[nrcmds++].f=(XCICMDP) fn;
  return 0;
  }

/* currently executing file name */
static char curfile[67];

/* Command to transfer execution from one file to another
   Only works from inside a file, and is not enabled by
   default. If your program wants to use GOTO it must enable
   the command by calling: addcmd("GOTO",gotocmd); */
XCICMD gotofunc(int cmd,char *s,struct udata *data)
  {
  FILE *f;
  if (cmd==2)
    {
    printf("Execute commands from an ASCII file\n");
    return;
    }
  if (cmd==1||!s||!*s)
    {
    printf("goto executes commands from an ASCII file\n"
           "Usage: goto FILENAME\n");
    return;
    }
/* open file */
  f=fopen(s,"r");
  if (!f)
    {
    printf("Can't open %s\n",s);
    perror(s);
    return;
    }
  if (!interactive)
    {
    printf("Use goto only from command files\n"
           "Use do to execute a file\n");
    return;
    }
/* register as current file */
  strcpy(curfile,s);
  fclose(xci_infile);
  xci_infile=f;
  }

/* Do a command file (sort of like a batch file) */
XCICMD dofunc(int cmd,char *s,struct udata *data)
  {
  FILE *ifile;
  struct fstack recall;
  if (cmd==2)
    {
    printf("Do commands from an ASCII file\n");
    return;
    }
  if (cmd==1||!s||!*s)
    {
    printf("Do executes commands from an ASCII file\n"
           "Usage: do FILENAME\n");
    return;
    }

/* open file */
  ifile=fopen(s,"r");
  if (!ifile)
    {
    printf("Can't open %s\n",s);
    perror(s);
    return;
    }
  if (interactive)
     {
/* store current file name so we can resume later */
     if (!(recall.fp=strdup(curfile)))
        {
        printf("Out of memory\n");
        fclose(ifile);
        return;
        }
/* store position in current file and close it */
     recall.pos=ftell(xci_infile);
     fclose(xci_infile);
     }
  else
     {
/* no current file, so remember this handle but don't close it */
     baseio=xci_infile;
     recall.fp=NULL;
     }
/* add recall to linked list of nested files */
  recall.next=instack;

/* make new file current */
  strcpy(curfile,s);
  xci_infile=ifile;

/* mark nesting level */
  interactive++;

/* make recall the head of the fstack linked list */
  instack=&recall;

/* call command recursively */
  command(NULL,NULL,0,data,NULL);

/* close useless file */
  fclose(xci_infile);
/* restore old file */
  if (instack->fp!=NULL)  /* is it a file? */
     {
/* open it */
     xci_infile=fopen(instack->fp,"r");
     if (!xci_infile)
        {
/* serious error! file vanished! reset to top level */
        printf("Error opening %s\n",instack->fp);
        xci_infile=baseio;
        interactive=0;  /* bad error if nested */
        }
     else
        {
/* reposition old file */
        fseek(xci_infile,instack->pos,SEEK_SET);
/* make it current */
        strcpy(curfile,instack->fp);
        }
/* release memory used for file name */
     free(instack->fp);
     }
  else
     {
/* reset to console */
     xci_infile=baseio;
     }
/* fix up linked list */
  instack=instack->next;
  interactive--;
  }

/* Link a dll */
XCICMD linkfunc(int cmd,char *s,struct udata *data)
  {
  if (cmd==2)
    {
    printf("Add user-defined commands\n");
    return;
    }
  if (cmd==1||!s||!*s)
     {
     printf("Add user-defined commands via a DLL\n"
       "Usage: link DLLNAME\n");
     return;
     }
  if (adddll(s))
    {
    printf("Unable to load dll: %s\n",s);
    }
  }

/* Quit */
XCICMD quitfunc(int cmd,char *s,struct udata *data)
  {
  if (cmd==0) { xci_exitflag=1; return; }
/* long and short help message */
  printf("Exits to DOS\n");
  }

/* provide general help (scan from end to 0 call with cmd==2)
   or specific help find command and call with cmd==1 */
XCICMD helpfunc(int cmd,char *s,struct udata *data)
  {
  int i,j=0;
  if (cmd==2) printf("Get help\n");
  if (cmd==1) printf(
  "Use the help command to learn about the available"
  " commands\nUse HELP for a list of help topics"
  " or \"HELP topic\""
  " for help on a specific topic.\n");
  if (cmd) return;
/* call user's prehelp */
  (*xcif_prehelp)();
/* if specific command... */
  if (s&&*s)
    {
/* find it and ask it about itself (command==1)
   This allows user DLL commands to provide help
   for themselves */
    i=findcmd(s);
    if (i==-1) printf("No such command: %s\n",s);
    else cmds[i].f(1,NULL,NULL);
    }
  else
/* No specific command -- do help for them all (command==2)
   Again, this allows user DLL commands to provide their own
   help */
    for (i=nrcmds-1;i>=0;i--)
      {
      char buf[22];
/* might be a lot of commands -- pause on screenfulls */
      if (!(++j%25))
        {
        printf("--More--");
        j=0;
        if (!getch()) getch();
        putchar('\n');
        }
/* print header */
      strncpy(buf,cmds[i].cmd,20);
      strcat(buf,":");
      printf("%-21.21s",buf);
/* ask command for short help */
      cmds[i].f(2,NULL,NULL);
      }
/* call user's post help */
  (*xcif_posthelp)();
  }

