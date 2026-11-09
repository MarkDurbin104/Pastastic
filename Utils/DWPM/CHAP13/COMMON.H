/* Common stuff for CAT286B1 and CAT286B2 -- only include once */
#ifndef CAT_COMMON
#define CAT_COMMON
/* strings... */
static char *cerr_msg="Critical Error: ";
static char *cerr_prompt="\n\r<R>etry, <F>ail, <I>gnore? ";
static char *err_tbl[]=
  {
  "Write protect",
  "Invalid drive",
  "Drive not ready",
  "Bad command",
  "CRC error",
  "Bad request",
  "Seek error",
  "Unknown format",
  "Sector not found",
  "Paper out",
  "Write error",
  "Read error",
  "General error",
  "??? - error",   /* unused error codes */
  "??? - error",
  "Invalid disk change"
  };

#define FAIL_OK 0x800
#define RETRY_OK 0x1000
#define IGNORE_OK 0x2000
/* Zero flag */
#define ZFLAG 64



/* output character via bios -- avoid using DOS call inside
   critical error handler */
void bios_out(char *p)
  {
/* Don't take up too much room on the stack! */
  static union REGS r1;
  while (*p)
    {
    r1.x.ax=0xE00|*p++;
    r1.x.bx=0;
    int86(0x10,&r1,&r1);
    }
  }

int bios_in(void)
  {
/* Don't take up too much room on the stack! */
  static union REGS r1;
  r1.x.ax=0;
  int86(0x16,&r1,&r1);
  return r1.h.al;
  }

int critical(unsigned int rax,unsigned int rdi)
  {
  int c;
  char key[4],beep[2];
  key[1]='\r';
  key[2]='\n';
  beep[1]=key[3]='\0';
  beep[0]='\a';
/* use BIOS function to print message */
  bios_out(cerr_msg);
  bios_out(err_tbl[rdi&0xF]);
  bios_out(cerr_prompt);
/* get character from BIOS */
  while (1)
    {
    c=toupper(bios_in());
    key[0]=c;
    bios_out(key);
    if (c=='F'&&(rax&FAIL_OK))
      return 3;
    if (c=='R'&&(rax&RETRY_OK))
      return 1;
    if (c=='I'&&(rax&IGNORE_OK))
      return 0;
/* No abort option implemented in this example */
    bios_out(beep);
    }
  }

#endif
