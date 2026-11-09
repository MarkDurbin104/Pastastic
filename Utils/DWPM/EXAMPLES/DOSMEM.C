/*  
DOSMEM.C
bcc286 dosmem.c
*/

#include <stdlib.h>
#include <stdio.h>
#include <dos.h>

#ifndef MK_FP
#define MK_FP(s, o) ((void _far*)((((unsigned long)(s)) << 16) + (o)))
#endif

main()
{
    unsigned segment, avail;
    char far *fp;
    _asm mov ah, 48h
    _asm mov bx, 0FFFFh
    _asm int 21h
    _asm jc error
    _asm mov segment, ax
    fp = MK_FP(segment, 0);
    *fp = 'x';   /* make sure it's genuine */
    printf("Allocated 0FFFFh paragraphs: %Fp\n", fp);
    return 0;
error:
    _asm mov avail, bx
    printf("Only %04Xh paragraphs available\n", avail);
    return 1;
}

