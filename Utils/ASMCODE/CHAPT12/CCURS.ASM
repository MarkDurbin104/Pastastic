
 ;************************************************************
 ;  Program CCurs ( Chapter 12 )
 ;
 ;  The PC screen input/output library    Version 1.0
 ;  Subroutine for moving the cursor to a specified position
 ;  Copyright (c): A.I.Sopin, Voronezh, Russia 1990 - 1991
 ;
 ;  This subroutine can be called from programs written in C/C++
 ;
 ;  C description: void CCURS (int U, int V)
 ;
 ;  Parameters:
 ;
 ;  U   - Y coordinate of the cursor (row): 1 -- 50
 ;  V   - X coordinate of the cursor (colomn): 1 -- 80
 ;
 ;  All parameters are  through the stack
 ;
 ;***********************************************************
	.MODEL  SMALL
	.CODE
	PUBLIC  _CCURS
_CCURS  PROC    NEAR
	push    bp
	mov     bp,sp
	push    ax
	push    bx
	push    cx
	push    dx
;----------------------------------------------------------
;  Moving the cursor to the position specified
	mov     dh,[bp+4]               ;  accept parameter U
	dec     dh                      ;  convert to BIOS standard (from 0)
	mov     dl,[bp+6]               ;  accept parameter U
	dec     dl                      ;  convert to BIOS standard (from 0)
	xor     bh,bh                   ;  video page 0 is used
	mov     ah,2                    ;  function 02h - set cursor
	int     10h                     ;  BIOS video service call
;----------------------------------------------------------
;  Restore registers and return to caller
	pop     dx
	pop     cx
	pop     bx
	pop     ax
	pop     bp
	RETN
_CCURS  ENDP
	END
