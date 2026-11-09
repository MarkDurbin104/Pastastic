;-----------------------------------------------------------
;
;  Program WrChar ( Chapter 8 ) 
;
;  Procedure for writing a character+ attribute at the address: DH, DL
;
;  Author:  A.I.Sopin      VSU,     Voronezh, 1992
;
;  Input parameters:
;
;  AL - a character to be written
;
;  AH - attribute of a character
;
;  BH  - number of a video page (0, 1, 2, 3)
;
;  BL  - type of a video adapter (is determined using  VIDTYP)
;
;  DH  - line of a character (0 --- 49)
;
;  DL  - column of a character (0 --- 79)
;
;  CX  - quantity of characters to be written
;
;  ES  - segment address of a video buffer
;
;  The direct writing to vibeo buffer is used
;-----------------------------------------------------------

.MODEL  SMALL
.CODE
WRCHAR  PROC    FAR
	PUBLIC  WRCHAR
	push    ax                ;
	push    bx                ;
	push    cx                ;
	push    dx                ;
	push    si                ;
	push    di                ;
	push    es                ;
	push    bp                ;
	mov     bp,ax             ;  save character + attribute
	mov     si,cx             ;  counter of characters being written
	mov     CS:CGA,bl         ;  type of video adapter
;  Computation an address of character + attribute in the video buffer
	mov     al,dh             ;  multiplier - line of a start of output
	mov     cl,160            ;  multiplier =160
	mul     cl                ;  compute offset of video buffer
	xor     cx,cx             ;
	mov     cl,dl             ;  add column of output
	sal     cx,1              ;  *2
	add     ax,cx             ;  compute offset of a character
	mov     di,ax             ;
	mov     bl,bh             ;  BL - number of video page
	mov     cl,12             ;  number of shifts *4096
	sal     bx,cl             ;  page number *4096
	add     di,bx             ;  address taking offset into account
	mov     cx,si             ;  counter of characters been written
;  External cycle of writing acharacter + attribute to video buffer
Cycle0: cmp     CS:CGA,1          ;    CGA ?
	jne     Write             ;  don't check for interference
	mov     dx,3DAH           ;  status register
;  Waiting for completion of retrace
Cycle1: in      al,dx             ;  read status register 
	test    al,1              ;  is it retrace now  ?
	jnz     Cycle1            ;  yes, wait for completion
;  Test , if writing is possible (to avoid interference)
Cycle2: in      al,dx             ;  read status register
	test    al,1              ;  is it retrace now (may we write)?
	jz      Cycle2            ;  no, continue interrogation
Write:  mov     ax,bp             ;  restore character + attribute
	stosw                     ;  pass character + attribute
	loop    Cycle0            ;  continue output
;  Restoring the registers been used and exit
	pop     bp
	pop     es
	pop     di
	pop     si
	pop     dx
	pop     cx
	pop     bx
	pop     ax
	RETF
CGA     DB      0                 ;  1 -  CGA indicator
WRCHAR  ENDP
	END
