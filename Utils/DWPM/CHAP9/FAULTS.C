/* Catching faults with InterruptRegister()
   Compile:
   Borland: BWINCOMP faults
   Microsoft: MWINCOMP faults
*/
#include "winpmode.h"
#include <windows.h>
#include <toolhelp.h>
#include <dos.h>

#ifndef __BORLANDC__
#pragma check_stack(off)
#endif


/* Fault handler */
void _far _saveregs _loadds on_gp(
     WORD ax, WORD intno, WORD hand, WORD faultip,
     WORD faultcs, WORD flags,WORD sp, WORD ss)
     {
     int cmd;
     static char ad[25];
/* Set up box title */
     wsprintf(ad,"Fault - CS:IP=%04X:%04X",faultcs,faultip);
     if ((intno&0xFF)==0)
        cmd=MessageBox(NULL,"Divide by zero",ad,
            MB_ICONSTOP|MB_ABORTRETRYIGNORE|MB_TASKMODAL);
     else if ((intno&0xFF)==13)
        cmd=MessageBox(NULL, "GP Fault", ad,
            MB_ICONSTOP|MB_ABORTRETRYIGNORE|MB_TASKMODAL);
/* Only look at GP and /0 faults */
     else return;
/* Act on command */
     switch (cmd)
       {
/* Abort -- terminate application */
       case IDABORT:
          MessageBox(NULL,
           "Some system resources may not be freed",
           "Warning",MB_ICONSTOP|MB_OK|MB_TASKMODAL);
          TerminateApp(NULL,NO_UAE_BOX);

/* Retry -- since we don't try to correct things this will
   just cause the same fault again. */
       case IDRETRY:
/* Can't do this in C easily (if at all) */
          _asm {
/* blow C's stack */
            mov sp,bp
/* restore registers from _savereg */
            pop es
            pop ds
            pop di
            pop si
            pop bp
            pop bx   /* ignore pushed sp! */
            pop bx
            pop dx
            pop cx
            pop ax
/* remove toolhelp's stack */
            add sp,10
/* return to application */
            iret
            }

/* no action for ignore -- pass to default handler */
        }
     }

#ifndef __BORLANDC__
#pragma check_stack
#endif



char *test()
  {
  extern HANDLE hInst;
  char _far *p,x,y=0;
  FARPROC gphnd;
  GlobalPageLock(FP_SEG(on_gp));
  gphnd=MakeProcInstance((FARPROC)on_gp,hInst);
  InterruptRegister(NULL,gphnd);
/* create bad pointer */
  FP_SEG(p)=0;
/* access it */
  x=*p;
/* divide by zero */
  x=10/y;

/* Clean up */
  InterruptUnRegister(NULL);
  FreeProcInstance(gphnd);
  GlobalPageUnlock(FP_SEG(on_gp));
  return "Done";
  }

