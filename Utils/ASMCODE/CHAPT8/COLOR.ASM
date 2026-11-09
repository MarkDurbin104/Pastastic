;*********************************************************************
;
;  Program Color ( Chapter 8 )
;
;  The PC screen interfacing system.                             
;
;  Author: A.I.SOPIN,    Voronezh
;
:  The procedure for the screen clearing (filling with the prescribed color)
;
;  Usage:     Call  COLOR
;
;  Entry point: CLEAR - clearing of B&W-screen
;
;  Designed to be called from Assembler programs
;
;  Input parameters are passed through the registers:
;
;  AH - an attribute for colors of the background and text,
;       isn't used for CLEAR
:  CH - the starting line of the area to be cleared (1 - 25,43,50)
;  DH - the last line of the area to be cleared (1 - 25,43,50) 
;  AH - the background and text attribute (not used for CLEAR)
;
;********************************************************************
;
CODE    SEGMENT 'CODE'
COLOR   PROC    FAR
	PUBLIC  COLOR
	ASSUME  CS:CODE
	jmp     short Pushr
;  The extra entry point for the B&W screen clearing
CLEAR   LABEL   FAR
	PUBLIC  CLEAR
	mov     ah,07h            ;  attribute of B&W screen
;  Saving all registers used
Pushr:  push    ax
	push    bx
	push    cx
	push    dx
	push    ds
	push    es
	push    si
	push    di
;----------------------------------------------------------
;  Parsing parameters given
	mov     bx,ax             ;  saving an attribute of color
	xor     ax,ax             ;
	mov     dl,ch             ;  M
	mov     al,ch             ;  starting line number for change is M
	dec     al                ;  (M-1)
	mov     cl,160            ;
	mul     cl                ;  (M-1)*160
	mov     di,ax             ;  offset for sending to video buffer
	xor     cx,cx             ;
	mov     cl,dh             ;  N
	sub     cl,dl             ;  (N - M)
	inc     cl                ;  quantity of lines 
	xor     ax,ax             ;
	mov     al,cl             ;  first multiplier = (N-M+1)
	mov     dl,80             ;  second multiplier=80
	mul     dl                ;
	mov     cx,ax             ;  quantity of spaces being passed
;
;----------------------------------------------------------
;  Determining the display type (to know the video buffer segment address)
	mov     dx,0B000H           ;  the monochrome video buffer address
	xor     si,si               ;  clearing the CGA indicator 
	mov     ax,40H              ;  segment address of the BIOS area
	mov     ES,ax               ;  ES -address of  BIOS data area
	mov     al,ES:[10H]         ;  reading the hardware list   0040:0010
	and     al,30h              ;  clearing the unnecessary bits
	cmp     al,30h              ;  monochrome display ?
	je      M0                  ;  YES !
;  Search for active color diplay adapter: EGA (VGA) or CGA
	mov     dx,0B800H               ; the color video buffer address
	mov     si,1                    ; CGA indicator
	cmp     byte ptr ES:[87H],0     ; no EGA ?
	jz      M0                      ; EGA isn't present
	test    byte ptr ES:[87H],08h   ; is EGA not active ?
	jnz     M0                      ; 3-d bit =1  - EGA isn't active
	xor     si,si                   ; Clearing off the CGA indicator
M0:     mov     ES,dx                   ; segient address of a video buffer
	mov     bl,' '                  ; fill character - space
	and     si,si                   ; CGA ?
	jz      Erase                   ; no, no interference
  ;  Putting out the CGA-screen before filling the video buffer
  ;  The current video mode value is stored at the address 0:[465h]
	xor     ax,ax                   ;  the BIOS data area segment address
	mov     al,es:[465h]            ;  the current mode value
	mov     CS:B465,al              ;  save current mode value
	and     al,0F7h                 ;  switch off the video signal
	mov     dx,3D8h                 ;  mode register       
	out     dx,al                   ;  switch off display  
;  Writing space + attribute at the address of video buffer
Erase:  mov     ES:[DI],bx              ;  passing of space + attribute
	add     DI,2                    ;
	loop    Erase                   ;  to the start of the loop
	and     si,si                   ;    CGA ?
	jz      Popr                    ;  no,no interference
 ;  switching on the screen after filling the buffer
	mov     dx,3D8h                 ;  mode register
	mov     al,CS:B465              ;  switch on video signal
	out     dx,al                   ;  switch on display
;----------------------------------------------------------
; Restoring registers and exit 
Popr:   pop     di
	pop     si
	pop     es
	pop     ds
	pop     dx
	pop     cx
	pop     bx
	pop     ax
	RETF
COLOR   ENDP
B465    DB      0                       ;  save current mode 
CODE    ENDS
	END
