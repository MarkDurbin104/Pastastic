;-----------------------------------------------------------
;
;  Program RdChar ( Chapter 8 ) 
;
;  Procedure for reading a character + attribute at the address: DH,DL  
;
;  Author:  A.I.Sopin      VSU,     Voronezh, 1992
;
;  Input parameters
;
;  BH - number of a video page  (0, 1, 2, 3)
;
;  BL - type of a video adapter (is determined using  VIDTYP)
;
;  DH - line of a character (0 --- 49)
;
;  DL - column of a character (0 --- 79)
;
;  ES - segment address of the videobuffer
;
;  Output parameters:
;
;  AH  -attribute of the character been read
;
;  AL  -the character been read
;
;-----------------------------------------------------------

.MODEL  SMALL
.CODE
RDCHAR  PROC    FAR
        PUBLIC  RDCHAR
        push    bx                ;
        push    cx                ;
        push    dx                ;
        push    di                ;
        push    es                ;
        mov     CS:CGA,bl         ;  video adapter type
;  Computing the address of the charpacter + attribute in the video buffer
        mov     al,dh             ;  multiplier - line of the cursor
        mov     cl,160            ;  multiplier =160
        mul     cl                ;  computing offset of video buffer
        xor     cx,cx             ;
        mov     cl,dl             ;  add column of cursor
        sal     cx,1              ;  *2
        add     ax,cx             ;  computing offset of a character
        mov     di,ax             ;
        mov     bl,bh             ;  BL - number of video page
        mov     cl,12             ;  quantity of shifts *4096
        sal     bx,cl             ;  number of page *4096
        add     di,bx             ;  address taking offset into account
        cmp     CS:CGA,1          ;  CGA ?
        jne     Read              ;  don't check for the interference
        mov     dx,3DAH           ;  status register
;  Waiting for the completition of beam retrace
Cycle0: in      al,dx             ;  reading status register
        test    al,1              ;  is retrace being executed ?
        jnz     Cycle0            ;  yes, wait for a completion
;  Check, is reading is possble ( to avoid interference)
Cycle1: in      al,dx             ;  reading status register
        test    al,1              ;  is retrace being executed (may we read) ?
        jz      Cycle1            ;  no, continue testing
Read:   mov     ax,ES:[DI]        ;  pass the character + attribute
;  Restoring the registers been used and exit
        pop     es
        pop     di
        pop     dx
        pop     cx
        pop     bx
        RETF
CGA     DB      0                       ;  1 - CGA indicator
RDCHAR  ENDP
        END
