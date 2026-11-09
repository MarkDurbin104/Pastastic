/* Header for initializing 48-bit far pointers */
#ifndef PTRSET_H
#define PTRSET_H

struct PTRSET_OVERLAY
  {
  int off;
  short seg;
  };

#define FP_SEG(p) (((struct PTRSET_OVERLAY *)&p)->seg)
#define FP_OFF(p) (((struct PTRSET_OVERLAY *)&p)->off)

#endif
