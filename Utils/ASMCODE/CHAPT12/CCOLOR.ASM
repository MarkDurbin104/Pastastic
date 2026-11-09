 ;************************************************************
 ;  Program CColor ( Chapter 12 )
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
 ;  M   - first line to be cleared
 ;  N   - last line to be cleared
 ;  Ch  - background and character attributes
 ;
 ;  All parameters are  through the stack
 ;
 ;***********************************************************
	.MODEL  SMALL
	PUBLIC  CCOLOR
EXTRN   COLOR : FAR
	.CODE
CCOLOR PROC    NEAR C USES AX BX CX DX, M:byte, N:byte, Chb:byte
;----------------------------------------------------------
;  Accrpt parameters passed
	mov     CH,M                  ;  number of first line M
	mov     DH,N                  ;  number of last line N
	mov     AH,Chb                ;  video attribute  Chb
	Call    far ptr COLOR              ;
;  Restore registers and exit
	ret
CCOLOR ENDP
	END
