;***********************************************************************
;
;  Program PG0807 ( Chapter 8 )
;
;  Demo program for working with video pages
;
;  Author: A.I.Sopin,  VSU,  Voronezh,  1992
;
;  The BIOS video service is used (function 0Eh of interrupt 10h)
;
;***********************************************************************
.model  small

EXTRN   VIDTYP : FAR, PUTSTR : FAR, WRCHAR : FAR

LF      EQU     10      ;  Line Feed
CR      EQU     13      ;  Carriage Return

;----------------------------------------------------------
.stack
.data
STRING  DB      80 dup ('E'), 0
TEXT0   DB      ' Video Page Demonstrion (BIOS  INT  10h).  Press any key...'
	DB      CR, LF, '$'
TEXT1   DB      ' Video Type = '
VTypeS  DB      'X'
	DB      '   MODE = '
VModeS  DB      'X'
	DB      '    Press any key...$'
VT      DB      0
VMODE   DB      0               ; original video mode saved
PAGEN   DB      ' Video Page Number is = '
PagenS  DB      'X'
	DB      '                 ', 0
;----------------------------------------------------------
.CODE
.startup
	mov     ah,0Fh                  ;  function 0Fh - get video mode
	int     10h                     ;  BIOS video service call
	mov     VMODE,al                ;  save original video mode
	mov     ah,0                    ;  function 00h - set video mode
	mov     al,2                    ;  video mode 2 - 80x25  B & W
	int     10h                     ;  BIOS video service call
	mov     ah,2                    ;  function 02h - set cursor
	xor     dx,dx                   ;  cursor position 0, 0
	xor     bh,bh                   ;  video page 0 is used
	int     10h                     ;  BIOS video service call
	lea     dx,TEXT0                ;  address of text to be output
	mov     ah,9                    ;  function 09h - output text string
	int     21h                     ;  DOS service call
	xor     ah,ah                   ;  function 00h - get key
	int     16h                     ;  BIOS keyboard service call
;  determine and report the video adapter type and video mode
	Call    VIDTYP                  ;
	mov     VT,al                   ;  save video type
	mov     es,dx                   ;  ES points to video buffer
	mov     VTypeS,al               ;  Video Adapter Type
	or      VTypeS,30h              ;  Bin ---> ASCII
	mov     ah,0Fh                  ;  function 0Fh - get video mode
	int     10h                     ;  BIOS video service call
	mov     VModeS,al               ;  Video Mode
	or      VModeS,30h              ;  Bin ---> ASCII
	lea     dx,TEXT1                ;  address of text to be output
	mov     ah,9                    ;  function 09h - output text string
	int     21h                     ;  DOS service call
	xor     ah,ah                   ;  function 00h - get key
	int     16h                     ;  BIOS keyboard service call
	mov     ah,2                    ;  function 02h - set cursor
	xor     dx,dx                   ;  cursor position 0, 0
	xor     bh,bh                   ;  video page 0 is used
	int     10h                     ;  BIOS video service call
	mov     ah,2                    ;  function 02h - Set Cursor
	mov     dx,1950h                ;  cursor location ot of screen
	xor     bh,bh                   ;  video page 0 is used
	int     10h                     ;  BIOS video service call
;-------------------------------------------------------------------
;  Create four video pages
	mov     bx,0                    ; initial video pge number
	mov     cx,4                    ; number of video pages
M0:     push    cx                      ; save cycle counter
	mov     PagenS,bh               ; current video page number
	or      PagenS,30h              ; convert to character
	lea     si,PAGEN                ; addres of string to be output
	mov     ah,07h                  ; attribute for output
	mov     cx,80                   ; max length of string
	xor     dx,dx                   ; output from beginning of string
	mov     bl,VT                   ; video card type
	Call    PUTSTR                  ; call output subroutine
	mov     dx,0100h                ; row 2 column 1
	mov     cx,1920                 ; output 24 lines
	mov     ah,07h                  ; attribute
	mov     al,bh                   ; AL - current video page number
	or      al,30h                  ; convert to character
	Call    WRCHAR                  ; output 1920 characters
	pop     cx                      ; restore cycle counter
	inc     bh                      ; modify video page number
	loop    M0                      ; next performance of cycle
;-------------------------------------------------------------------
;  Switching video pages
	mov     cx,4                    ;  number of video pages
	xor     bh,bh                   ;  initial video page = 0
M1:     xor     ah,ah                   ;  function 0 - read key
	int     16h                     ;  BIOS video service call
	mov     ah,5                    ;  Function - Set Display Page
	mov     al,bh                   ;  Display Page
	int     10h                     ;  Set Display Page
	inc     bh                      ;  Next Display Page
	loop    M1                      ;
	xor     ah,ah                   ;  function 00h - get key
	int     16h                     ;  BIOS keyboard service call
;-------------------------------------------------------------------
;  Finish the program and return to MS-DOS
Exit:   mov     al,VMODE                ;  AL - original video mode
	xor     ah,ah                   ;  function 00h - set video mode
	int     10h                     ;  BIOS video service call
	mov     ax,4C00h                ;  Return Code =0
	int     21h                     ;  DOS service call
;-------------------------------------------------------------------
	END
