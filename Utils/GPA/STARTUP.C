#ifdef __DPMI16__

void setfilemax (void);

#pragma startup setfilemax 0

void setfilemax (void)
{
    asm { //;   If default number of file handles have changed then tell DOS
		cmp     _nfile, 20
		jbe     NoChange

		cmp     [_osmajor], 3   ;// Check for >= DOS 3.3
		jb      NoChange
		ja      DoChange
		cmp     [_osminor], 1Eh
		jb      NoChange
    } DoChange:
    asm {
		mov     ax, 5801h      //; Set last fit allocation
		mov     bx, 2
		int     21h
		jc      BadInit

		mov     ah, 67h        //; Expand handle table
		mov     bx, _nfile
		int     21h
		jc      BadInit

		mov     ax, 5801h      //; Set first fit allocation
		mov     bx, 0
		int     21h
		jnc     NoChange

    } BadInit:
		abort ();

    NoChange:
    return;
}

#endif
