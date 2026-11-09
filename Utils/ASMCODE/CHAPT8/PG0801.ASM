;***********************************************************************
;
;  Program PG0801 ( Chapter 8 )
;
;  Output text onto the screen
;
;  Author: A.I.Sopin, VSU, Voronezh, 1992
;
;  The technique of writing into video buffer is used (procedure WRCHAR)
;
;***********************************************************************
.model  small

EXTRN   VIDTYP : FAR, PUTSTR : FAR, WRCHAR : FAR

;----------------------------------------------------------
.stack
.data
VIDBUF  DW      0
TEXT0   DB      ' Output to Screen  (Low Level).  Press any key...', 0
TEXT1   DB      ' Video adapter type = '
VTypeS  DB      'X'
	DB      '   MODE = '
VModeS  DB      'X'
	DB      '    Press any key...', 0
VT      DB      0
VMODE   DB      0
;----------------------------------------------------------
.code
.startup
	mov     ah,0Fh                  ;  function 0Fh - get video mode
	int     10h                     ;  BIOS video service call
	mov     VMODE,al                ;  save original video mode
	Call    VIDTYP                  ;  determine video adapter type
	mov     VIDBUF,dx               ;  video buffer address
	mov     VT,al                   ;  save video adapter type
	xor     ah,ah                   ;  function 00h - set video mode
	mov     al,2                    ;  80x25  B & W
	int     10h                     ;  BIOS video service call
;  Hide cursor before output
	mov     dx,1950h                ;  cursor position oyside screen
	xor     bh,bh                   ;  video page 0
	mov     ah,2                    ;  function 02h - set cursor
	int     10h                     ;  BIOS video service call
	mov     cx,80                   ;  max length of string
	mov     ah,07h                  ;  attribute byte
	lea     si,TEXT0                ;  start address of text for output
	xor     dx,dx                   ;  output from position 0, 0
	xor     bh,bh                   ;  video page 0
	Call    PUTSTR                  ;  output prompt
	xor     ah,ah                   ;  function 00h - get key
	int     16h                     ;  BIOS keyboard service call
;  determine and report the video adapter type
	mov     al,VT                   ;
	mov     VtypeS,al               ;  Video Adapter Type
	or      VtypeS,30h              ;  Bin ---> ASCII
	mov     ah,0Fh                  ;  function 0Fh - get video mode
	int     10h                     ;  BIOS video service call
	mov     VModeS,al               ;  Video Mode
	or      VModeS,30h              ;  Bin ---> ASCII
	mov     cx,80                   ;  max length of string
	mov     ah,07h                  ;  attribute byte - white on black
	lea     si,TEXT1                ;  start address of text for output
	xor     bh,bh                   ;  video page 0
	mov     dx,0100h                ;  output from position 0, 1
	Call    PUTSTR                  ;  output adapter type
	xor     ah,ah                   ;  function 00h - get key
	int     16h                     ;  BIOS keyboard service call
;-------------------------------------------------------------------
;  Output text onto screen
	xor     dx,dx                   ;  output from position 0, 0
	mov     ah,07h                  ;  attribute byte - white on black
	mov     al,'E'                  ;  character to be output
	xor     bx,bx                   ;  video page 0
	mov     cx,1920                 ;  output 24 lines
	mov     bl,VT                   ;  BL - video adapter type
	mov     es,VIDBUF               ;
	Call    WRCHAR                  ;  output 1920 characters
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
