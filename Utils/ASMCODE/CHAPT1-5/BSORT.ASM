;*********************************************************************
;
;  Program BSort ( Chapter 4 )
;
;  Character arrays sorting. Version 1.4
;
;  Author: A.I.Sopin, Voronezh University, 16/03/93 1993
;
;  Using from assembler programs:
;
;  Call  BSORT
;
;  Modified bubblesort algorithm is used
;
;  Parameters passed
;
;  Entry parameters:
;  -----------------
;
;  DS:SI - address of an array to be sorted
;  CX    - the array element length
;  DX    - number od elements
;
;  Sorting order
;
;  AX = 0  - increasing
;       1  - decreasing
;
;  Output (error code in the AX register)
;  --------------------------------------
;  AX = 0 - normal finish
;       1 - elements longer than 48 bytes
;       2 - invalid parameters specified
;
;  The source array left unchanged
;
;********************************************************************
.model       large
   public    bsort
MaxLen       equ       48                   ; maximum record length
.code
BSORT   PROC    FAR pascal uses bx cx dx es si di bp
;----------------------------------------------------------
;  Check parameters passed
        cmp     cx,MaxLen       ;  array length valid?
        jng     ChkN            ;  less than maximum - continue
        mov     ax,1            ;  indicate "elements too long"
        jmp     Exit            ;  return
ChkN:   cmp     dx,0            ;  number of elements = 0?
        jg      Work            ;  if not continue
        mov     ax,2            ;  indicate "no elements in array"
        jmp     Exit            ;  return
;----------------------------------------------------------
Work:   mov     CS:SrtOrd,ax    ;  store Sort Order
        cld                     ;  Clear Direct Flag
        mov     CS:RecLen,cx    ;  store Record Length
        mov     CS:RecNum,dx    ;  store Number Of Records
        mov     CS:AddrArr,si   ;  store Array Address
        push    ds              ;  push DARA segment addres
        pop     es              ;  ES now points to DATA segment
;  External loop (WHILE SWP = 1, i.e while elements moved)
ExtLoop:mov     CS:SWP,0        ;  indicate "no elements moved"
        mov     ax,0            ;  Normal Return Code
        dec     CS:RecNum       ;  decrease number of records to process
        jz      Exit            ;  if no more records - exit
        mov     dx,CS:RecNum    ;  of DX - number records left
        mov     bp,CS:AddrArr   ;  starting address of array
        mov     CS:BP0,bp       ;  save address of first record
;  Nested loop (comparing adjacent records)
M1:     mov     si,CS:BP0       ;  address of current record
        mov     di,si           ;  address of following record
        mov     cx,CS:RecLen    ;  record length
        add     di,cx           ;  address of next record
        cmp     CS:SrtOrd,0     ;  increasing?
        jnz     DecrS           ;  AX <> 0 - decreasing
IncrS:  repe    cmpsb           ;  compare adjacent records
        jbe     Swapped         ;  if following < current
        jmp     short SWAP      ;  swap records
DecrS:  repe    cmpsb           ;  compare adjacent records
        jae     Swapped         ;  if following > current
;  Swapping records
SWAP:   mov     cx,CS:RecLen    ;  CX - record length
        mov     bp,CS:BP0       ;  BP - address of current record
        mov     bx,bp           ;  BX points to current record
        add     bx,cx           ;  now BX points to next record
SwBytes:mov     al,DS:[BP]      ;  byte from current record into AL
        xchg    al,[bx]         ;  swap bytes in AL and next record
        mov     DS:[BP],al      ;  put byte into next record
        inc     bp              ;  next byte in current record
        inc     bx              ;  next byte in next record
        loop    SwBytes         ;  repeat swapping
        mov     CS:SWP,1        ;  indicate swappingg
;  advance parameters of external cycle
Swapped:mov     ax,CS:RecLen    ;  AX - record length
        add     CS:BP0,ax       ;  BP points to next record
        dec     dx              ;  decrease number of records to process
        jnz     M1              ;  next step of nested cycle
        cmp     CS:SWP,0        ;  have elements been swapped?
        jnz     ExtLoop         ;  yes - repeat process
        mov     ax,0            ;  Normal Return Code
;  Restore registers and return (exit code in AX)
Exit:   ret
BSORT   ENDP
;----------------------------------------------------------
;  Data area in CODE segments
SrtOrd  DW      0                       ;
RecLen  DW      0                       ;
RecNum  DW      0                       ;
AddrArr DW      0                       ;
BP0     DW      0                       ;  address of current record
SWP     DB      0                       ;  swappings indicator
        END
