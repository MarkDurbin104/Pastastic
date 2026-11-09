/* Try to allocate 8 Meg from Windows -- this may take
   awhile. */
#include "winpmode.h"
#include <windows.h>

#define MEGABYTE 1048576L

char result[64];

char *test()
  {
  HGLOBAL h;
  DWORD siz=8*MEGABYTE;
/* Try 8 Meg first. If that doesn't work keep trying
less and less in 1 Meg decrements */
  while (siz&&!(h=GlobalAlloc(GHND,siz))) siz-=MEGABYTE;
  if (h) GlobalFree(h);
  sprintf(result,"Allocated %ld megabytes",siz/MEGABYTE);
  return result;
  }

