 ;************************************************************
 ;  Program BColor ( Chapter 12 )
 ;
 ;  The PC screen input/output library    Version 1.0
 ;  Subroutine for clearing the display screen
 ;      (filling it with a specified color)
 ;  Copyright (c): A.I.Sopin, Voronezh, Russia 1990 - 1991
 ;
 ;  This subroutine can be called from programs written
 ;  in MS BASIC, FORTRAN and PASCAL
 ;
 ;  Type of parameters: Integer*1, Integer*2, Integer*4
 ;
 ;  Parameters:
 ;
 ;  M  - first line to be cleared
 ;  N  - last line to be cleared
 ;  C  - background and character attributes
 ;
 ;  All parameters are passed by reference, through the stack
 ;
 ;  The FAR calls are used
 ;***********************************************************
 ;
	extrn   color: far
	public  bcolor
 .      code
 bcolor proc    basic far uses ax bx cx dx, 
		M: far ptr word, N: far ptr word, C: far ptr word

 ;----------------------------------------------------------
 ;  accept parameters passed
	lds     bx,C                       ;  full address C into DS:BX
	mov     AH,[bx]                    ;  load C value into AH
	mov     bx,N                       ;  offset N into DX
	mov     DH,[bx]                    ;  load value N into DH
	mov     bx,M                       ;  offset M into DX
	mov     CH,[bx]                    ;  load value M into CH
	Call    COLOR                      ;  call functional subroutine
	RET
FCOLOR  ENDP
	END
