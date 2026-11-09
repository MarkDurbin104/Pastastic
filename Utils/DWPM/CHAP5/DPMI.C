/* Real mode program to detect DPMI
   Borland: bcc dpmi.c
   Microsoft: cl dpmi.c
*/
#include <stdio.h>
#include <stdlib.h>
#include <dos.h>


void main()
  {
  union REGS r;
  struct SREGS s;
  segread(&s);

/* use INT 0x2F function 0x1687 to detect DPMI */
  r.x.ax=0x1687;
  int86x(0x2f,&r,&r,&s);

/* if AX non-zero, no DPMI */
  if (r.x.ax)
    {
    printf("DPMI not present.\n");
    exit(1);
    }

/* DH and DL contain the version number */
  printf("DPMI version %d.%d detected.\n",r.h.dh,r.h.dl);

/* if bit 0 of BX is set then 32-bit else 16-bit */
  if (r.x.bx&1)
    printf("32-bit support detected.\n");

/* CL contains code for processor type */
  printf("Processor=%s.\n",
       r.h.cl==2?"80286":
          (r.h.cl==3?"80386":
          (r.h.cl==4?"80486":"Unknown")));

/* DPMI hosts may require a private data area for its
  own purposes. The size of this area in paragraphs
  (16 bytes) is in SI */
  printf("This host requires %d "
         "paragraphs of private data.\n",r.x.si);

/* Entry point in ES:DI -- calling this address will switch
   you to protected mode */
  printf("Entry point =%04X:%04X.\n",s.es,r.x.di);
  exit(0);
  }
