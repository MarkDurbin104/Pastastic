;***********************************************************************
;  Program PMouse1 ( Chapter 10 )
;
;  The demo program for mouse (Text Mode)
;
;  Author:  A.I.Sopin, Voronezh University. 1993
;
;  The interrupt 33h (mouse service) is used
;
;  The mouse driver required
;
;***********************************************************************
	EXTRN   INSYM4 : FAR
	.MODEL  SMALL
	.STACK
;----------------------------------------------------------
	.DATA
BELL    EQU     07      ;  sound signal
LF      EQU     10      ;  Line Feed
CR      EQU     13      ;  Carriage Return
TEXT0   DB      " The MOUSE demo program  (INT 33h). "
	DB      "  Press any key to continue...", BELL, CR, LF, "$"
TEXT1   DB      " The mouse driver is not installed !!!."
	DB      "  Press any key...", BELL, CR, LF, "$"
TEXT2   DB      " An active mouse driver found."
	DB      "  Press any key...", BELL, CR, LF, "$"
TXT0    DB      " Function 0 - initialize mouse."
	DB      "  Press any key...", BELL, "$"
TXT1    DB      CR, " Function 1 - show mouse cursor."
	DB      "  Press any key...", BELL, "$"
TXT2    DB      CR, " Function 2 - hide mouse cursor."
	DB      "  Press any key...", BELL, "$"
TXT3    DB      CR, " Function 3 - press mouse key.   (Enter -Exit).        "
	DB      BELL, CR, LF, "$"
TXT3L   DB      CR, " Left button pressed.   CODE=0X."
	DB      " COL=XXXX. ROW=XXXX.", BELL, "$"
TXT3R   DB      CR, " Right button pressed.  CODE=0X."
	DB      " COL=XXXX. ROW=XXXX.", BELL, "$"
TXT3M   DB      CR, " Middle buttom pressed. CODE=0X."
	DB      " COL=XXXX. ROW=XXXX.", BELL, "$"
TXT10   DB      CR, " Function 10 - define text cursor.  Press any key..."
	DB      BELL, CR, LF, "$"
VMODE   DB      0                       ;  video mode saved
ATTR    DB      0                       ;
ROW0    DB      0
CX0     DW      0
DX0     DW      0
Eight   DW      8
;----------------------------------------------------------
	.CODE
OutMsg  macro   Txt
	lea     dx,Txt                  ;  addres of message
	mov     ah,09h                  ;  function 09h - output text string
	int     21h                     ;  DOS  service call
	endm
WaitKey macro
	mov     ah,0                    ;  function 0 - wait for key pressed
	int     16h                     ;  BIOS keyboard service
	endm
SetCurs MACRO   Row,Column
	mov     ah,2                    ;  function 02h - set cursor
	xor     bh,bh                   ;  video page 0 is used
	mov     dh,&Row                 ;  cursor row
	mov     dl,&Column              ;  cursor column
	int     10h                     ;  BIOS video service call
	ENDM
;----------------------------------------------------------
.STARTUP
	mov     ah,0Fh                  ;  function 0Fh - get video mode
	int     10h                     ;  BIOS video service call
	mov     VMODE,al                ;  save current video mode
	mov     ah,0                    ;  function 0 - set video mode
	mov     al,3                    ;  80x25  Text
	int     10h                     ;  BIOS video service call
;  Output initial message
	OutMsg  TEXT0                   ;  output initial message
	WaitKey
;  check for mouse driver present
	mov     ax, 03533h              ;  function 35h - get interrupt vector
	int     21h                     ;  DOS service call
	mov     ax,es                   ;  segment address of handler
	or      ax,bx                   ;  AX - segment .OR. offset of int 33
	jz      Nomouse                 ;  if full addres is 0 - no mouse
	mov     bl,es:[bx]              ;  get first instrucyion of handler
	cmp     bl,0CFh                 ;  is this IRET instruction?
	jne     Begin                   ;  if not - driver installed
Nomouse:OutMsg  TEXT1                   ;  output message "driver not found"
	WaitKey                         ;  wait for key pressed
	jmp     Exit                    ;  Exit program
;-------------------------------------------------------------------
Begin:  OutMsg  TEXT2                   ;  output message "driver installed"
	WaitKey                         ;  wait for key pressed
;-------------------------------------------------------------------
;  Initialize mouse and report status (function 0 of INT 33h)
Func0:  OutMsg  TXT0                    ;  output message "function 0"
	WaitKey
	xor     ax,ax                   ;  Initialize mouse
	int     33h                     ;  mouse service call
	cmp     ax,0                    ;  is mouse installed?
	jnz     Func1                   ;  if so, pass to function 1
	jz      Exit                    ;  if not, exit program
;-------------------------------------------------------------------
;  Function 1 - show the mouse cursor
Func1:  OutMsg  TXT1                    ;  output message "function 1"
	mov     ax,1                    ;  function 01 - show mouse cursor
	int     33h                     ;  mouse service call
	WaitKey
;-------------------------------------------------------------------
;  Function 2 - hide cursor
Func2:  OutMsg  TXT2                    ;  output message "function 2"
	mov     ax,2                    ;  function 02 - hide mouse cursor
	int     33h                     ;  mouse service call
	WaitKey
;-------------------------------------------------------------------
;  Function 10 - set text cursor
Func10: OutMsg  TXT10                   ;  output message "function 10"
	WaitKey
	mov     ax,10                   ;  function 10 - Define Text Cursor
	xor     bx,bx                   ;  software cursor will be used
	mov     cx,0FFFFh               ;  screen Mask
	mov     dx,4700h                ;  cursor Mask
	int     33h                     ;  mouse service call
	mov     ax,1                    ;  function 01 - show mouse cursor
	int     33h                     ;  mouse service call
;  Output colored strips on screen
	mov     cx,15                   ;  number of lines to be output
	mov     ATTR,17h                ;  bacground for first line (blue)
	mov     ROW0,9                  ;  first line painted is line 9
Str15:  SetCurs ROW0,0                  ;  function 02h - set cursor position
	mov     ah,9                    ;  function 09 - output char+attr
	mov     al,20h                  ;  character to be output - blank
	mov     bh,0                    ;  video page 0
	push    cx                      ;  save line counter
	mov     cx,80                   ;  CX - number of characters output
	mov     bl,ATTR                 ;  background/character attribute
	int     10h                     ;  BIOS video service
	add     ATTR,10h                ;  change background
	inc     ROW0                    ;  to next line
	pop     cx                      ;  restore lines counter
	loop    Str15                   ;  next step (draw next line)
;-------------------------------------------------------------------
;  Function 03 - report cursor location and key status
Func3:  SetCurs 3,0                     ;  function 02h - set cursor position
	OutMsg  TXT3                    ;  output message "function 3"
ChkKBD: mov     ah,1                    ;  function 01h - check keyboard buffer
	int     16h                     ;  BIOS keyboard service
	jz      ContF3                  ;  if no key pressed, continue
	jmp     Exit                    ;  exit if key pressed
;  determining mouse keys pressed
ContF3: mov     ax,3                    ;  func. 03 - button status and location
	int     33h                     ;  mouse service call
	mov     CX0,cx                  ;  save  X coordinate (column)
	mov     DX0,dx                  ;  save  Y coordinate (row)
	test    bx,1                    ;  left button pressed?
	jnz     M3L                     ;
	test    bx,2                    ;  right button pressed?
	jnz     M3R                     ;
	test    bx,4                    ;  middle button pressed ?
	jnz     M3M                     ;
	jmp     short ChkKBD            ;  no button pressed - check again
M3L:    lea     dx,TXT3L                ;  address of message "left button"
	jmp     short   M3MES           ;  to output message
M3R:    lea     dx,TXT3R                ;  address of message "right button"
	jmp     short   M3MES           ;  to output message
M3M:    lea     dx,TXT3M                ;  address of message "miiddle button"
;  Output number and code of mouse key pressed
M3MES:  or      bl,30h                  ;  convert key number into ASCII code
	mov     di,dx                   ;  address of message into DI
	mov     ds:[di+31],bl           ;  place ASCII code of key pressed
	push    dx                      ;  save address of message
	mov     si,4                    ;  lehgth of variable to be edited
	lea     bp,[di+38]              ;  address for placing edited text
	mov     ax,CX0                  ;  low part is column
	mov     cl,3                    ;  Numbers of Shift
	shr     ax,cl                   ;  divide value in pixel by 8 to get X
	xor     dx,dx                   ;  high part of number to be edited
	Call    INSYM4                  ;  convert number in DX:AX to string
	mov     si,4                    ;  lehgth of variable to be edited
	lea     bp,[di+48]              ;  address for placing edited text
	mov     ax,DX0                  ;  low part is row
	mov     cl,3                    ;  Numbers of Shift
	shr     ax,cl                   ;  divide value in pixel by 8 to get Y
	xor     dx,dx                   ;  high part of number to be edited
	Call    INSYM4                  ;  convert number in DX:AX to string
;  Output cursor coordinates and key code
	pop     dx                      ;  address of text buffer
	mov     ah,9                    ;  Output message to screen
	int     21h                     ;  DOS service call
	jmp     ChkKBD                  ;  check whether key was pressed
;-------------------------------------------------------------------
;  Terminate program and exit to DOS
Exit:   mov     al,VMODE                ;  remember video mode on entry
	mov     ah,0                    ;  function 0 - set video mode
	int     10h                     ;  BIOS video service
	mov     ah,0Ch                  ;  function 0Ch - flash keyboard buffer
	int     21h                     ;  DOS service call
	mov     ax,4C00h                ;  function 4Ch - terminate process
	int     21h                     ;  DOS service call
	END
