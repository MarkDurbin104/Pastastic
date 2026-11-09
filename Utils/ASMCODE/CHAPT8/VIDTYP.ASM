;**********************************************************************
;
;  Program VidTyp ( Chapter 8 )
;
;  Screen I/O library system.  Version 1.0
;
;  The program for determining the video adapter type.
;
;  Author:  A.I.Sopin Voronezh,  1990 --- 1992 
;
;  Usage: Call  VIDTYP
;
;  Results:
;
;  AL    -Type of Videoadapter
;
;  AL =0 -MDA
;  AL =1 -CGA
;  AL =2 -MCGA
;  AL =3 -EGA
;  AL =4 -VGA
;
;  DX    -Video Segment Address (for text mode):
;
;  DX = 0B000h - if monochrome display  (MDA, EGA, VGA, MCGA)
;  DX = 0B800h - if color display       (CGA, EGA, VGA, MCGA)
;
;
;  For  EGA  only !!! :
;  --------------------
;
;  BH =0 -color display, BH=1 -monochrome display
;
;  BL    -memory installed on  EGA  board:
;
;  0     -if   64 KB
;  1     -if  128 KB
;  2     -if  192 KB
;  3     -if  256 KB
;
;  CH    -feature bits (see Notes)
;
;  CL    -switch setting (see Notes)
;
;**********************************************************************
;
CODE    SEGMENT
	ASSUME  CS:CODE
VIDTYP  PROC    FAR
	PUBLIC  VIDTYP
;----------------------------------------------------------
CHKVGA: mov     ax,1A00h                ;  Request video info for VGA
	int     10h                     ;  Get Display Combination Code
	cmp     al,1Ah                  ;  Is VGA or MCGA present?
	jne     CHKEGA                  ;  No?  Then check for EGA
	cmp     bl,2                    ;  If VGA exists as secondary adapter,
	je      CGA                     ;  check for CGA and mono as primary
	jb      MONO                    ;
	cmp     bl,5                    ;  If EGA is primary, do normal
	jbe     CHKEGA                  ;  EGA checking
;
CHKMCGA:mov     al,2                    ;  Yes? Assume MCGA
	mov     dx,0B800h               ;  Segment for  Color
	cmp     bl,8                    ;  Correct assumption?
	jbe     VGA                     ;  VGA only (BL = 7 - 8)
MCGA:   cmp     bl,0Bh                  ;  Monocrome Display ?
	jne     EXIT                    ;  Return
	mov     dx,0B000h               ;  Segment for Monochrome
	jmp     short EXIT              ;  Return
;
VGA:    mov     al,4                    ;  Assume it's VGA color
	cmp     bl,8                    ;  VGA  Color ?
	je      EXIT                    ;  Return
	mov     dx,0B000h               ;  Segment for Monochrome
	jmp     short EXIT              ;  Return
;
CHKEGA: mov     ah,12h                  ;  Call EGA status function
	mov     bl,10h                  ;  Get Configuration Information
	sub     cx,cx                   ;  Clear status bits
	int     10h                     ;  Get Configuration Information
	jcxz    CHKCGA                  ;  If CX is unchanged, not EGA
EGA:    mov     al,3                    ;  Set structure fields for EGA
	mov     dx,0B800h               ;  Segment for  Color
	and     bh,bh                   ;  Color Display ?
	jz      EXIT                    ;  Yes, Return
	mov     dx,0B000h               ;  Segment for Monochrome
	jmp     short EXIT              ;  Return
;
CHKCGA: xor     ax,ax                   ;
	mov     es,ax                   ;  BIOS  segment
	mov     ax,es:[410h]            ;  0:410 -equipment list
	and     al,30h                  ;  If bits 4-5 set, monochrome
	cmp     al,30h                  ;  Monochrome text mode?
	je      MONO                    ;  Yes? Continue
CGA:    mov     al,1                    ;  No?  Must be CGA
	mov     dx,0B800h               ;  Segment for  Color
	jmp     short EXIT              ;  Return
MONO:   xor     al,al                   ;  Set MONO
	mov     dx,0B000h               ;  Segment for  MONO
;----------------------------------------------------------
;  Finish program and return
EXIT:   RETF
VIDTYP  ENDP
CODE    ENDS
	END
