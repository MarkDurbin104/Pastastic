/* Use DPMI to learn Windows memory statistics
Compile with:
Borland:
BWINCOMP MEMINFO

Microsoft:
MWINCOMP MEMINFO

*/


#include <dos.h>
#include "winpmode.h"

struct
  {
  unsigned long maxfree_block;
  unsigned long unlock_max;
  unsigned long locked_max;
  unsigned long lin_size;
  unsigned long unlock_total;
  unsigned long free_total;
  unsigned long physical;
  unsigned long lin_free;
  unsigned long pgfile_size;
  char reserved[12];
  } meminfo;

char *test()
  {
  union REGS r;
  struct SREGS s;
  char _far *buffer=(char _far *)&meminfo;
  segread(&s);
  r.x.ax=0x500;
  s.es=FP_SEG(buffer);
  r.x.di=FP_OFF(buffer);
  int86x(0x31,&r,&r,&s);
  win_printf("Free Memory Information",
     "Largest Free Block: %lu (bytes)   Free Pages: %lu",
     meminfo.maxfree_block, meminfo.free_total);
  win_printf("Virtual Memory Information",
     "Number of pages in page file=%lu",
     meminfo.pgfile_size);
  win_printf("Linear Memory Information",
     "Linear Address Size: %lu (pages)  Free: %lu (pages)",
     meminfo.lin_size,meminfo.lin_free);
  return "Done";
  }
