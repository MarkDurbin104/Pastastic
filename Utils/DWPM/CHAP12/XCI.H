/* XCI.H  Header for XCI command interpreter
 See MAKEFILE.XCI for compile instructions
*/

#ifndef XCI_HEADER
#define XCI_HEADER

/* type for command functions */
#define XCICMD void far

/* Pointer to command function */
typedef void (far * XCICMDP)(int cmd,char far *line,void *udata);

/* Various hooks */
extern char *xci_prompt;   /* string to prompt with */
extern FILE *xci_infile;   /* input file */
extern int xci_exitflag;   /* set to exit XCI */
extern int xci_defaultbrk; /* default break handling */
/* function to prompt with */
extern void (*xcif_prompt)();
/* function to call before help */
extern void (*xcif_prehelp)();
/* function to call after help */
extern void (*xcif_posthelp)();
/* function to get input */
extern char *(*xcif_input)();

/* main function prototype */
int command(char *dll,char *startfile,int caseflag,
            void far *ustruc,XCICMDP userfunc);

/* add command (not from DLL) */
int addcmd(char *cmdnam,XCICMDP fn);
#define addcmd(a,b) addcmd(a,(XCICMDP)b)

#endif
