/***************************************************
 *                                                 *
 * FPM32.H - C language header for FPM32           *
 *                                                 *
 ***************************************************/
#ifndef FPMHEADER
/* fixed point type */
typedef struct
 {
 char sign;
 char scale;
 unsigned long num;
 } FIXED;


/* Scale factor
  use - 1000.0 for 3 places, 100.0 for 2 places etc. */
#define SFACTOR (10000.0)

#define CVTTYPE float

#ifdef __cplusplus
extern "C"
{
#endif

/* Assembly core functions (from FPM32.ASM) */
#ifdef __BORLANDC__
extern FIXED faddxy(FIXED,FIXED),fsubxy(FIXED,FIXED),
       fmulxy(FIXED,FIXED),fdivxy(FIXED,FIXED);
#else
/* Microsoft handles functions that return struct
   different than Borland! */
FIXED fpmmsc_rv;  /* Global return value */

extern void faddxy(FIXED _far *,FIXED,FIXED),
            fsubxy(FIXED _far *,FIXED,FIXED),
            fmulxy(FIXED _far *,FIXED,FIXED),
            fdivxy(FIXED _far *,FIXED,FIXED);

#define faddxy(a,b) (faddxy(&fpmmsc_rv,a,b),fpmmsc_rv)
#define fsubxy(a,b) (fsubxy(&fpmmsc_rv,a,b),fpmmsc_rv)
#define fmulxy(a,b) (fmulxy(&fpmmsc_rv,a,b),fpmmsc_rv)
#define fdivxy(a,b) (fdivxy(&fpmmsc_rv,a,b),fpmmsc_rv)
#endif

extern int bitscan(int dir,unsigned long lword);

/* C helpers (from FPMC.C) */
FIXED floattofix(CVTTYPE f);
CVTTYPE fixtofloat(FIXED f);
int fixtoint(FIXED f);

#ifdef __cplusplus
}
#endif

#endif
