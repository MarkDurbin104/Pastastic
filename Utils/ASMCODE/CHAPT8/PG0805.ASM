;***********************************************************************
;
;  Program PG0806 ( Chapter 8 ) 
;
;  Outpt windows of certain color on the screen
;
;  An example of blinking-intensity controlling
;
;  Author: A.I.Sopin     VSU,  Voronezh,  1992
;
;***********************************************************************

.model small
.stack
EXTRN   BLINK : FAR, WIND : FAR
.data
WIND1   DB      'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'  ; coordinates: (row, column)
	DB      '³       WINDOW 1        ³'  ; start (3,4)
	DB      '³                       ³'  ; end  (12,28)
	DB      '³   An Ordinary Mode    ³'
	DB      '³  Background = Brown   ³'
	DB      '³   Attribute = 60h     ³'
	DB      '³                       ³'
	DB      '³                       ³'
	DB      '³                       ³'
	DB      'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
;
WIND2   DB      'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'  ; coordinates: (row,column)
	DB      '³       WINDOW 2        ³'  ; start (3,40)
	DB      '³                       ³'  ; end  (12,64)
	DB      '³   An Ordinary Mode    ³'
	DB      '³  Bacground requested  ³'
	DB      '³    Bright Yellow      ³'
	DB      '³   Attribute = 0Eh     ³'
	DB      '³    Press Any Key      ³'
	DB      '³                       ³'
	DB      'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
;
WIND3   DB      'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'  ; coordinates (row,column)
	DB      '³       WINDOW 3        ³'  ; start (3,40)
	DB      '³                       ³'  ; end  (12,64)
	DB      '³   An Intensive Mode   ³'
	DB      '³   On  Bright Yellow   ³'
	DB      '³    Attribute = 0Eh    ³'
	DB      '³                       ³'
	DB      '³                       ³'
	DB      '³                       ³'
	DB      'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
TEXT    DB      ' An example of blinking-intensinty controlling.'
	DB      ' Press any key...$'
;----------------------------------------------------------
.code
.Startup
	mov     ah,0Fh                  ; function 0Fh - Get Video Mode
	int     10h                     ; BIOS video service
	mov     ah,08h                  ; Read Character/Attribute
	int     10h                     ; BIOS video service call
	mov     bh,ah                   ; attribute for clearing window 
	mov     ah,06h                  ; function 06h - scroll window
	mov     al,0                    ; scroll full screen
	mov     cx,0                    ; left upper corner - 0,0
	mov     dx,184Fh                ; right upper corner = 24,79
	int     10h                     ; BIOS video service
	mov     ah,2                    ; function 02h - set cursor
	xor     dx,dx                   ; initial position 0,0
	mov     bh,0                    ; video page 0
	int     10h                     ; BIOS video service     
	lea     dx,TEXT                 ; text start address
	mov     ah,9                    ; fonction 09h - output text string
	int     21h                     ; DOS service call
	mov     ah,0                    ; function 0 - get key
	int     16h                     ; BIOS keyboard service
	mov     ah,2                    ; function 02h - set cursor
	mov     dx,1950h                ; position for cursor - 25,80
	mov     bh,0                    ; video page 0
	int     10h                     ; BIOS video service
;-------------------------------------------------------------------
;  Output Window 1 onto the screen
	mov     dh,3                    ;  row for window left upper corner
	mov     dl,4                    ;  column for window left upper corner
	mov     ch,12                   ;  row for window right down corner
	mov     cl,28                   ;  column for window right upper
	xor     bh,bh                   ;  video page 0
	lea     si,WIND1                ;  DS:SI - address of window text
	mov     ah,60h                  ;  attribute (black on brown)
	Call    WIND                    ;  display window 1
;  Output Window 2 onto the screen
	mov     dh,3                    ;  row for window left upper corner
	mov     dl,40                   ;  column for window left upper corner
	mov     ch,12                   ;  row for window right down corner
	mov     cl,64                   ;  column for window right upper
	xor     bh,bh                   ;  video page 0
	lea     si,WIND2                ;  DS:SI - address of window text
	mov     ah,0E0h                 ;  attribute (black on yellow)
	Call    WIND                    ;  display window 2
;  After pressing a key the blinking/intensity mode will be changed
	mov     ah,0                    ; function 0 - get key
	int     16h                     ; BIOS keyboard service
;  Change the meaning of blinking/intensity bit
	xor     al,al                   ;  switch blinking OFF
	Call    BLINK                   ;  change blinking/intensity mode
;  Output Window 1 onto the screen
	mov     dh,3                    ;  row for window left upper corner
	mov     dl,4                    ;  column for window left upper corner
	mov     ch,12                   ;  row for window right down corner
	mov     cl,28                   ;  column for window right upper
	xor     bh,bh                   ;  video page 0
	lea     si,WIND1                ;  DS:SI - address of window text
	mov     ah,60h                  ;  attribute (black on brown)
	Call    WIND                    ;  display window 1
;  Output Window 2 onto the screen
	mov     dh,3                    ;  row for window left upper corner
	mov     dl,40                   ;  column for window left upper corner
	mov     ch,12                   ;  row for window right down corner
	mov     cl,64                   ;  column for window right upper
	xor     bh,bh                   ;  video page 0
	lea     si,WIND3                ;  DS:SI - address of window text
	mov     ah,0E0h                 ;  attribute (black on yellow)
	Call    WIND                    ;  display window 2
;-------------------------------------------------------------------
;  Finish the program and return to MS-DOS
Exit:   mov     ah,0                    ; function 0 - get key
	int     16h                     ; BIOS keyboard service
	mov     al,1                    ; set blinking ON
	Call    BLINK                   ; call BLINK/INTENSITY control
	mov     ax,4C00h                ; Return Code = 0
	int     21h                     ; DOS service call
	END
