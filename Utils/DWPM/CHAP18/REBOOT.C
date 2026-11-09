/* REBOOT.C - Disable ^ALT-DEL for CodeBuilder programs
   See CB386.C
*/
#include <stdio.h>
#include <i32.h>
#include <stk.h>
#include <dos.h>
#include <conio.h>

/* Scan code for Delete */
#define DEL_SCANCODE 0x53
/* Shift status for Ctrl-Alt */
#define CTRL_ALT 0xC
/* Keyboard controller */
#define KBDATA 0x60
#define KBPORT 0x61
/* Where to send EOI command */
#define EOIPORT 0x20
/* Non-specific End of interrupt command */
#define NSEOI   0x20


/* When running DOS we replace the keyboard interrupt
   (INT 9) */

/* old INT 9 handler */
static void (*oldint9)();

#pragma interrupt(ourint9)

/* replacement interrupt handler */
static void ourint9()
  {
  int code,temp;
/* pointer to CodeBuilder stack frames */
  _XSTACK *frame=_get_stk_frame();
/* pointer to BIOS shift status byte */
  unsigned char *shift_status=(unsigned char *)0x417;
/* read keyboard */
  code=inp(KBDATA);

/* DEL is scan code 0x53 --
   if *shift_status&0xc==0xc then control and Alt are down */
  if (code!=DEL_SCANCODE||(*shift_status&CTRL_ALT)!=CTRL_ALT)
     _chain_intr(oldint9);
/* will not allow ^ALT-DEL */
/* consume key from keyboard -- these inp and outp
   statements are just like the ones you would use
   in a regular DOS program */
/* read control byte */
  temp=inp(KBPORT);
/* set bit 7 (acknowledge) and write */
  outp(KBPORT,temp|0x80);
/* write with bit 7 clear */
  outp(KBPORT,temp);
  outp(EOIPORT,NSEOI);
/* Tell CodeBuilder not to reissue interrupt */
  frame->opts=_STK_NOINT;
  return;
  }

/* This function locks the page ourint9 is on so it can't be
   swapped out. 4K is the minimum size, and surely ourint9
   isn't that big.... */
static lockint9(int flag)
  {
  static lock=0;
  if (flag!=lock)
    {
    lock=flag;
    if (flag)
      _dpmi_lockregion(ourint9,4096);
    else
      _dpmi_unlockregion(ourint9,4096);
    }
  }

/********************** External interfaces ***************/

/* Disable ^ALT-DEL */
void noreboot()
  {
  lockint9(1);
  oldint9=_dos_getvect(9);
  _dos_setvect(9,ourint9);
  }

/* Enable ^ALT-DEL */
void okreboot()
  {
  lockint9(0);
  _dos_setvect(9,oldint9);
  }
