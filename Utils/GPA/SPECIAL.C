#include <stdlib.h>
#include <stdio.h>

#ifdef __DPMI16__
void setfilemax(void);
#pragma startup setfilemax 0
void setfilemax(void)
{
    asm {
        cmp _nfile,20
        jbe NoChange
        cmp [_osmajor],3
        jb NoChange
        ja DoChange
        cmp [_osminor],0x1E
        jb NoChange
    } DoChange:
    asm {
        mov ax,0x5801
        mov bx,2
        int 0x21
        jc BadInit

        mov ax,0x67
        mov bx,_nfile
        int 0x21
        jc BadInit

        mov ax,0x5801
        mov bx,0
        int 0x21
        jnc NoChange

    } BadInit:
        abort();
    NoChange:
    return;
}
#endif // def __DPMI16__


