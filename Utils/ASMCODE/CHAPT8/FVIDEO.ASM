;**********************************************************************
;
;  Program FVideo ( Chapter 8 )
;
;  The PC screen interfacing system.                             
;
;  Author: A.I.SOPIN,    Voronezh
;
;  Usage: Call  FVIDEO (TYPE)
;
;  This procedure can be called from programs in Pascal, FORTRAN or BASIC
;
;  TYPE  - the type of video adapter (Integer *1, Integer *2) returned
;
;  TYPE =0 -MDA
;  TYPE =1 -CGA
;  TYPE =2 -MCGA
;  TYPE =3 -EGA
;  TYPE =4 -VGA
;
;  All parameters are passed by reference, through the stack
;
;  All address of parameters contains both segment and offset
;
;**********************************************************************
;
CODE    SEGMENT
FVIDEO  PROC    FAR
	PUBLIC  FVIDEO
	ASSUME  CS:CODE
	push    bp
	mov     bp,sp
	push    ax
	push    bx
	push    cx
	push    dx
;----------------------------------------------------------
;  determining the type of video adapter used
CHKVGA: mov     ax, 1A00h               ;  Request video info for VGA
	int     10h                     ;  Get Display Combination Code
	cmp     al, 1Ah                 ;  Is VGA or MCGA present?
	jne     CHKEGA                  ;  No?  Then check for EGA
	cmp     bl, 2                   ;  If VGA exists as secondary adapter,
	je      CGA                     ;  check for CGA and mono as primary
	jb      MONO
	cmp     bl, 5                   ;  If EGA is primary, do normal
	jbe     CHKEGA                  ;  EGA checking
;
CHKMCGA:mov     al,2                    ;  Yes? Assume MCGA
	cmp     bl, 8                   ;  Correct assumption?
	ja      EXIT                    ;  pass type
VGA:    mov     al,4                    ;  Assume it's VGA color
	jmp     short EXIT              ;  pass type
;
CHKEGA: mov     ah, 12h                 ;  Call EGA status function
	mov     bl, 10h
	sub     cx, cx                  ;  Clear status bits
	int     10h                     ;  Get Configuration Information
	jcxz    CHKCGA                  ;  If CX is unchanged, not EGA
EGA:    mov     al,3                    ;  Set structure fields for EGA
	jmp     short EXIT              ;  pass type
;
CHKCGA: xor     ax,ax                   ;
	mov     es,ax                   ;  BIOS  segment
	mov     ax,es:[410h]            ;  0:410 -equipment list
	and     al, 30h                 ;  If bits 4-5 set, monochrome
	cmp     al, 30h                 ;  Monochrome text mode?
	je      MONO                    ;  Yes? Continue
CGA:    mov     al,1                    ;  No?  Must be CGA
	jmp     short EXIT              ;  pass type
MONO:   mov     al,0                    ;  Set MONO
EXIT:   LDS     bx,[bp+6]               ;  address of parameter TYPE
	mov     [bx],al                 ;  pass type
;----------------------------------------------------------
;  Restore registers and exit
Popr:   pop     dx
	pop     cx
	pop     bx
	pop     ax
	pop     bp
	RETF    4
FVIDEO  ENDP
CODE    ENDS
	END
