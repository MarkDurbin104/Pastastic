;***********************************************************************
;
; Program PG0806 ( Chapter 8 )
;
; Creating a new image for a character (The letter "E" is changed")
;
; Author: A.I.Sopin,   Voronezh, 1992
;
;***********************************************************************
.MODEL  SMALL
EXTRN   VIDTYP : FAR

BEL     EQU     7
CR      EQU     13
LF      EQU     10
.STACK
;----------------------------------------------------------
.DATA 
TEXT0   DB      ' Demonstration of a special character creating.'
	DB        ' (Esc -Exit)', CR, LF,  "$"
TEXT1   DB      ' This is the text consisting of letters "EEEEEEEEEEEEEEEE".'
	DB      '  Press any key...',BEL, '$'
TEXT2   DB      CR, LF
	DB      ' EGA or VGA  card not installed !  Press any key...', '$'
VMODE   DB      0
NEWFONT DB      0,0,0FEh,0CCh,8Ch,2Ch,3Ch,2Ch,0Ch,8Ch,0CCh,0FEh,0,0

; row N     Character matrix  8x14      Hex representation
;
;   0     .  .  .  .  .  .  .  .     00h 
;   1     .  .  .  .  .  .  .  .     00h
;   2     Ü  Ü  Ü  Ü  Ü  Ü  Ü  .     0FEh     
;   3     Ü  Ü  .  .  Ü  Ü  .  .     0CCh
;   4     Ü  .  .  .  Ü  Ü  .  .     8Ch
;   5     .  .  Ü  .  Ü  Ü  .  .     2Ch
;   6     .  .  Ü  Ü  Ü  Ü  .  .     3Ch
;   7     .  .  Ü  .  Ü  Ü  .  .     2Ch
;   8     .  .  .  .  Ü  Ü  .  .     0Ch
;   9     Ü  .  .  .  Ü  Ü  .  .     8Ch
;  10     Ü  Ü  .  .  Ü  Ü  .  .     0CCh
;  11     Ü  Ü  Ü  Ü  Ü  Ü  Ü  .     0FEh
;  12     .  .  .  .  .  .  .  .     00h
;  13     .  .  .  .  .  .  .  .     00h

;----------------------------------------------------------
.CODE
.Startup
	mov     ah,0Fh                  ; function 0Fh - get video mode
	int     10h                     ; BIOS video service call
	mov     VMODE,al                ; save original video mode
;------
Begin:  mov     ah,0                    ; function 00h - set video mode
	mov     al,3                    ; 80x25  Color
	int     10h                     ; BIOS video service call
	xor     bh,bh                   ; video page 0
	mov     ah,2                    ; function 02h - set cursor
	mov     dx,0100h                ; initial position - 1,0
	int     10h                     ; BIOS video service call
;------
; Check whether EGA or VGA installed
	Call    VIDTYP                  ; determine cideo adapter type
	cmp     al,3                    ; EGA  or  VGA ?
	jnl     OK                      ; OK
	lea     dx,TEXT2                ; address of string for output
	mov     ah,9                    ; function 09h - output string
	int     21h                     ; DOS service call
	mov     ah,0                    ; function 00h - get key
	int     16h                     ; BIOS keyboard service call
	jmp     Exit                    ; to finishing program
;------
OK:     lea     dx,TEXT0                ; address of string for output
	mov     ah,9                    ; function 09h - output string
	int     21h                     ; DOS service call
	lea     dx,TEXT1                ; address of string for output
	mov     ah,9                    ; function 09h - output string
	int     21h                     ; DOS service call
	mov     ah,0                    ; function 00h - get key
	int     16h                     ; BIOS keyboard service call
	cmp     al,1Bh                  ; Esc ?
	je      Exit                    ; If so, finish the program
;-------------------------------------------------------------------
; Output new image for the letter "E"
	xor     bl,bl                   ; Block Number=0
	mov     bh,14                   ; size of character cell
	mov     cx,1                    ; number of character changed = 1
	mov     dx,45h                  ; offset for character "E"
	mov     ax,ds                   ; address of DATA segment
	mov     es,ax                   ; ES points to DATA segment
	mov     ax,1100h                ; Subfunction 11
	lea     bp,NEWFONT              ; ES:BP - Address of user font table
	int     10h                     ; BIOS video service call
	mov     ah,0                    ; function 00h - get key
	int     16h                     ; BIOS keyboard service call
	cmp     al,1Bh                  ; Esc ?
	je      Exit                    ; If so, finish the program
	mov     al,VMODE                ; AL - original video mode
	mov     ah,0                    ; function 00h - set video mode
	int     10h                     ; BIOS video service call
	jmp     Begin                   ; continue working
;-------------------------------------------------------------------
; Finish the program and return to MS-DOS
Exit:   mov     al,VMODE                ; AL - original video mode
	xor     ah,ah                   ; function 00h - set video mode
	int     10h                     ; BIOS video service call
	mov     ax,4C00h                ; Return Code =0
	int     21h                     ; DOS service call
	END
