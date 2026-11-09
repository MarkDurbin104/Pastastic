;***********************************************************************
;
;  Program PG0808 ( Chapter 8 )
;
;  The demo program for working with the cursor (low level)
;
;  Author:  A.I.Sopin      VSU,     Voronezh, 1992
;
;
;  This program uses the register technique for controlling the cursor
;  Following video registers are used:
;
;                       3D4h - CRTC  Address Register
;                       3D5h - Cursor Start Register (Index  0Ah)
;
;
;  External Subroutines:  COLOR, VIDTYP, PUTSTR
;
;***********************************************************************
.MODEL  SMALL
EXTRN   COLOR : FAR, VIDTYP : FAR, PUTSTR : FAR
.STACK
BEL     EQU     7       ;  Bell
LF      EQU     10      ;  Line Feed
CR      EQU     13      ;  Carriage Return

;----------------------------------------------------------
.DATA
STRING  DB      80 dup ('E'), 0
TEXT0   DB      CR, LF
	DB      ' The cursor controlling demo program.  Press any key...'
	DB      BEL, '$'
TEXT1   DB      CR, LF
	DB      ' Video Type = '
VTypeS  DB      'X'
	DB      '   MODE = '
VModeS  DB      'X'
	DB      CR,LF
	DB      ' This is the Hardware Cursor.          Press any key...', '$'
TEXT2   DB      ' Cursor is turned  Off.                Press any key...', 0
TEXT3   DB      CR, LF
	DB      ' This is the New Cursor.               Press any key...', BEL, '$'
VMODE   DB      0                       ;  The video mode
ADAPTER DB      0                       ;  The videoadapter type
VIDBUF  DW      0                       ;  The address of videobuffer
;----------------------------------------------------------
.CODE
.Startup
Start:
	mov     ah,0Fh                  ;  function 0Fh - get video mode
	int     10h                     ;  BIOS video service call
	mov     VMODE,al                ;  save original video mode
	mov     ah,0                    ;  function 00h - set video mode
	mov     al,3                    ;  video mode 3 - COLOR 80x25
	int     10h                     ;  BIOS video service call
	mov     ah,1Fh                  ;  white characters on blue background
	mov     ch,1                    ;  starting line 1
	mov     dh,25                   ;  last line 25
	Call    Color                   ;  fill screen with prescribed color
;  Output initial message
	lea     dx,TEXT0                ;  address of text to be output
	mov     ah,9                    ;  function 09h - output text string
	int     21h                     ;  DOS service call
	xor     ah,ah                   ;  function 00h - get key
	int     16h                     ;  BIOS keyboard service call
;  determine and report the video adapter type and video mode
	Call    VIDTYP                  ;  determine video adapter type
	mov     ADAPTER,al              ;  save  video adapter type
	mov     VIDBUF,dx               ;  segment address of video buffer
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
;-------------------------------------------------------------------
;  Swith the cursor OFF (6845 registers are used  for  MDA, CGA, VGA)
	cmp     ADAPTER,3               ;  EGA ?
	je      EGAOFF                  ;
	xor     ax,ax                   ;  Segment for  BIOS  Area
	mov     es,ax                   ;
	mov     dx,es:[463h]            ;  CRTC  Address Register
	mov     al,10                   ;  Index =10 (Cursor Start)
	out     dx,al                   ;  Select Index
	inc     dx                      ;  3D5h - Cursor Start Register
	mov     al,20h                  ;  Cursor is turned off
	out     dx,al                   ;  Execute
	jmp     short  MSG_OFF          ;
;  Switch the cursor OFF (BIOS  INT 10h, EGA  only)
EGAOFF: xor     bh,bh                   ;  Video Page Number
	mov     ah,3                    ;  Get Cursor
	int     10h                     ;  Call  BIOS  Service
	mov     ah,1                    ;  Set Cursor
	or      ch,30h                  ;
	int     10h                     ;  Cursor is turned off
;  Output message "Cursor turned OFF"
MSG_OFF:lea     si,TEXT2                ;  address of text to be output
	mov     ah,1Fh                  ;  white characters on blue background
	xor     bh,bh                   ;  video page 0
	mov     dx,0400h                ;  DH - row; DL - column
	mov     cx,80                   ;  max length of string
	mov     bl,ADAPTER              ;
	mov     es,VIDBUF               ;  segment address of video buffer
	Call    PUTSTR                  ;  output ASCIIZ string
	xor     ah,ah                   ;  function 00h - get key
	int     16h                     ;  BIOS keyboard service call
;  Set up the new cursor of increased size (for  MDA, CGA, EGA, VGA)
	xor     ax,ax                   ;
	mov     es,ax                   ;
	mov     dx,es:[463h]            ;  CRTC  Address Register
	mov     al,10                   ;  Index =10 (Cursor Start)
	out     dx,al                   ;  Select Index
	inc     dx                      ;  3D5h -Cursor Start Register
	mov     al,1                    ;  Cursor Start Line
	out     dx,al                   ;  Execute
;-------------------------------------------------------------------
;  Display the new cursor of increased size
	lea     dx,TEXT3                ;  address of text to be output
	mov     ah,9                    ;  function 09h - output text string
	int     21h                     ;  DOS service call
	xor     ah,ah                   ;  function 00h - get key
	int     16h                     ;  BIOS keyboard service call
;-------------------------------------------------------------------
;  Finish the program and return to MS-DOS
Exit:   mov     al,VMODE                ;  AL - original video mode
	xor     ah,ah                   ;  function 00h - set video mode
	int     10h                     ;  BIOS video service call
	mov     ax,4C00h                ;  Return Code =0
	int     21h                     ;  BIOS video service call
	END
