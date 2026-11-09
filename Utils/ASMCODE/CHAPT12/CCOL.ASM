
 ;************************************************************
 ;  Program CCol ( Chapter 12 )
 ;
 ;  The PC screen input/output library    Version 1.0
 ;  Subroutine for clearing the display screen
 ;      (filling it with a specified color)
 ;  Copyright (c): A.I.Sopin, Voronezh, Russia 1990 - 1991
 ;
 ;  This subroutine can be called from programs written in C/C++
 ;
 ;  Usage: CCOLOR( M, N, C)
 ;
 ;  Parameters:
 ;
 ;  M  - first line to be cleared
 ;  N  - last line to be cleared
 ;  C  - background and character attributes
 ;
 ;  All parameters are  through the stack
 ;
 ;***********************************************************
	DOSSEG
	.MODEL  SMALL
EXTRN   COLOR : FAR
	.CODE
	PUBLIC  _CCOLOR
_CCOLOR  PROC    NEAR
	push    bp
	mov     bp,sp
	push    ax
	push    bx
	push    cx
	push    dx

;----------------------------------------------------------
;  Accrpt parameters passed
	mov     CH,[bp+4]                  ;  number of first line M
	mov     DH,[bp+6]                  ;  number of last line N
	mov     AH,[bp+8]                  ;  video attribute  C
	Call    far ptr COLOR              ;
;  Restore registers and exit
	pop     dx
	pop     cx
	pop     bx
	pop     ax
	mov     sp,bp
	pop     bp
	RETN
_CCOLOR  ENDP
	END
