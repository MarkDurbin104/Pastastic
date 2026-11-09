;***********************************************************************
;
;  Program PG0804 ( Chapter 8 )
;
;  Drawing colored net in graphics mode
;
;  Author: A.I.Sopin, VSU, Voronezh, 1992
;
;  The low-level technique of programming adapter is used
;
;  The 8 pixels of a horizontal line are output at once
;
;***********************************************************************
.model  small
EXTRN   VIDTYP : FAR
.stack
.data
;----------------------------------------------------------
N       DW      0       ;  horizontal knots (0, 1 - 64)
M       DW      0       ;  vertical knots (0, 1 - 40)
X       DW      0       ;  horizontal coordinate of pixel (0 - 639)
Y       DW      0       ;  vertical coordinate of pixel (0 - 339)
H_Leng  DW      640     ;  number of points in horisontal direction
V_Leng  DW      400     ;  number of points in vertical direction
Nstr    DW      0       ;  number of lines for output (1 --- 340)
V_Count DW      0       ;  vertical pixel counter (1 --- 18)
Col     DB      0       ;  color (0 --- 15)
VMODE   DB      0       ;  original video mode
TEXT0   DB      ' Demo program for working in graphics mode  (LOW LEVEL).'
	DB      13,10
	DB      '8 pixels are output at once to increase the speed.'
	DB      13,10
	DB      ' Press any key for change color or ESC to exit.', 7, '$'
TEXT1   DB      13, 10
	DB      ' EGA or VGA  card not installed !  Press any key...', '$'
;----------------------------------------------------------
.code
.startup
	mov     ah,0Fh                  ;  function 0Fh - get video mode
	int     10h                     ;  BIOS video service call
	mov     VMODE,al                ;  save original video mode
	mov     ah,00                   ;  function 00h - set video mode
	mov     al,03h                  ;  mode 3 (80x25  color)
	int     10h                     ;  BIOS video service call
	mov     ah,2                    ;  function 02h - set cursor
	mov     dx,0100h                ;  initial cursor position - 1, 0
	mov     bh,0                    ;  video page 0
	int     10h                     ;  BIOS video service call
;  Check whether EGA or VGA installed
	Call    VIDTYP                  ;  determine cideo adapter type
	cmp     al,3                    ;  EGA  or  VGA ?
	jnl     Graph                   ;  OK
	lea     dx,TEXT1                ;  address of string for output
	mov     ah,9                    ;  function 09h - output string
	int     21h                     ;  DOS service call
	mov     ah,0                    ;  function 00h - get key
	int     16h                     ;  BIOS keyboard service call
	jmp     short Exit              ;  to finishing program
;  Output initial message and set graphics mode
Graph:  lea     dx,TEXT0                ;  address of string for output
	mov     ah,9                    ;  function 09h - output string
	int     21h                     ;  DOS service call
	xor     ah,ah                   ;  function 00h - get key
	int     16h                     ;  BIOS keyboard service call
	mov     ah,0                    ;  function 00h - set video mode
	mov     al,10h                  ;  Color  640x350
	int     10h                     ;  BIOS video service call
;  Setting the writing mode required
	mov     dx,3CEh                 ;  address register
	mov     al,5                    ;  index for register 5
	out     dx,al                   ;  send index
	inc     dx                      ;  3CFh - mode register
	xor     al,al                   ;  writing mode 0
	out     dx,al                   ;  send writing mode
	mov     Col,0                   ;  initial color (black)
	mov     ax,0A000h               ;  base address of video buffer
	mov     es,ax                   ;  ES points to video buffer
;-------------------------------------------------------------------
;  Output colored net into the screen
Loop0:  mov     Nstr,0                  ;  upper line number
Loop1:  Call    HORLINE                 ;  draw horizontal line
	Call    VLINES                  ;  output vertical lines
	add     Nstr,20                 ;  Next Line
	cmp     Nstr,340                ;  Last Line ?
	jl      Loop1                   ;
;  Change color when a key has been pressed
	xor     ah,ah                   ;  function 00h - get key
	int     16h                     ;  BIOS keyboard service call
	cmp     al,1Bh                  ;  Esc ?
	je      Exit                    ;  yes, finish program
	inc     Col                     ;  change color code
	cmp     Col,15                  ;  all colors shown?
	jng     Loop0                   ;  no, show next color
	mov     Col,0                   ;  set initial color (black)
	jmp     short Loop0             ;  continue
;-------------------------------------------------------------------
;  Finish program and return to MS-DOS
Exit:   mov     ax,0FF08h               ;  register number + all bits
	mov     dx,3CEh                 ;  address register
	out     dx,ax                   ;  write mask and mode
	mov     ax,0F02h                ;  index of card mask register
	mov     dx,3C4h                 ;  address register
	out     dx,ax                   ;  send address
	mov     ah,0                    ;  function 0 - set video mode
	mov     al,VMODE                ;  AL - original mode
	int     10h                     ;  BIOS video service call
	mov     ax,4C00h                ;  Function 4Ch - terminate process
	int     21h                     ;  DOS service call
;-------------------------------------------------------------------
;
;  Output pixel onto screen
;
;  AL  - color of pixel
;
;  CX  - horizontal coordinate  (column) X = (0 --- 640)
;
;  DX  - vertical coordinate (row)    Y = (0 --- 340)
;
;  ES  - base address of videobuffer ( 0A000h  for 16 colors 640x350)
;
;  Registers  AX, BX, SI, DI  are overwritten!
;
;-------------------------------------------------------------------
WR_DOT  PROC   NEAR
	mov     si,cx                   ;  horizontal coordinate
	mov     di,dx                   ;  vertical coordinate
	push    ax                      ;  save color
;  determining the mask for output the bit required
	and     cx,0007h                ;  remainder after dividing by 8
	mov     ah,80h                  ;  mask for 7th bit
	shr     ah,cl                   ;  mask
	mov     dx,3CEh                 ;  address of video register
	mov     al,8                    ;  register's number
	out     dx,ax                   ;  write mode and mask
;  determining the address of byte in graphics buffer
	mov     bx,si                   ;  X - horizontal coordinate
	shr     bx,1                    ;  /2
	shr     bx,1                    ;  /4
	shr     bx,1                    ;  /8 - offset from start of line
	mov     ax,di                   ;  Y - vertical coordinate
	xor     dx,dx                   ;  clear high part
	mov     cx,80                   ;  multiplier
	mul     cx                      ;
	add     bx,ax                   ;  BX - address of pixel in line
	mov     al,es:[bx]              ;  read latch value
;  set register of mask for color required
	mov     dx,3C4h                 ;  address register
	mov     ax,0F02h                ;  index of mask register
	out     dx,ax                   ;  set address
	mov     byte ptr es:[bx],0      ;  clear latch
	inc     dx                      ;  3C5h - data register
	pop     ax                      ;  restore color
	out     dx,al                   ;  send color code
	mov     byte ptr es:[bx],0FFh   ;  output pixel ES:[BX]
	mov     cx,si                   ;  horizontal coordinate
	mov     dx,di                   ;  vertical coordinate
	RETN
WR_DOT  ENDP
;-------------------------------------------------------------------
;
;  Output horizontal line (8 pixel ot a time)
;
;-------------------------------------------------------------------
HORLINE PROC   NEAR
	xor     cx,cx                   ;  X - initial column for output
HOR1:   mov     dx,3CEh                 ;  address register
	mov     ax,0FF08h               ;  mask and register number
	out     dx,ax                   ;  send mode and mask
;  Determining an address of byte in video buffer
	mov     bx,cx                   ;  X -horizontal coordinate
	shr     bx,1                    ;  /2
	shr     bx,1                    ;  /4
	shr     bx,1                    ;  /8 - offset from ctart of line
	mov     ax,Nstr                 ;  Y - vertical coordinate
	xor     dx,dx                   ;  clear high part
	mov     si,80                   ;  multiplier
	mul     si                      ;
	add     bx,ax                   ;  BX - address of first pixel in line
	mov     al,es:[bx]              ;  read latch contents
;  set the mask register for a color
	mov     dx,3C4h                 ;  address register
	mov     ax,0F02h                ;  index of card mask register
	out     dx,ax                   ;  send address
	mov     byte ptr es:[bx],0      ;  clear latch
	inc     dx                      ;  3C5h - data register
	mov     al,Col                  ;  AL - color code
	out     dx,al                   ;  send color code
	mov     byte ptr es:[bx],0FFh   ;  aitpot pixel in  ES:[BX]
	add     cx,8                    ;  number of next byte
	cmp     cx,H_Leng               ;  end of line?
	jl      HOR1                    ;  no, continue output
	RETN                            ;  return to caller
HORLINE ENDP
;-------------------------------------------------------------------
;
;  Drawing vertical lines from knots
;
;  Is performed after a horizontal line has been output
;
;  CX - horizontal pixel coordinate (row)
;
;  DX - vertical pixel coordinate (column)
;
;-------------------------------------------------------------------
VLINES  PROC   NEAR
	cmp     Nstr,340                ;  Last Line ?
	je      VLIN5                   ;  yes, return
	cmp     Nstr,0                  ;  first line ?
	jz      VLIN5                   ;  yes, return
	xor     cx,cx                   ;  initial column = 0
VLIN2:  mov     V_Count,20              ;  length of vertical line
	mov     dx,Nstr                 ;  initial row
	sub     dx,19                   ;  number of pixel
;  Output vertical line from upper line to current line
VLIN3:  mov     al,Col                  ;  pixel color
	Call    WR_DOT                  ;  output pixel
	inc     dx                      ;  address of bottom pixel
	dec     V_Count                 ;
	jg      VLIN3                   ;  continue output
;  Next knot in horizontal direction
	mov     si,32                   ;  length of string
	and     cx,cx                   ;  begiining of the line?
	jg      VLIN4                   ;  no
	mov     si,31                   ;  to knot 2
VLIN4:  add     cx,si                   ;  next horizontal knot
	cmp     cx,639                  ;  end of line?
	jng     VLIN2                   ;
VLIN5:  RETN                            ;  return
VLINES  ENDP
;-------------------------------------------------------------------
	END
