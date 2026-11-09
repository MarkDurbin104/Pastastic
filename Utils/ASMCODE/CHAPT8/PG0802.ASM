;***********************************************************************
;
;  Program PG0802 ( Chapter 8 )
;
;  Drawing colored net in graphics mode
;
;  Author: A.I.Sopin, VSU, Voronezh, 1992
;
;  BIOS video service is used (functiuon 0Ch of interrupt 10h)
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
TEXT0   DB      ' Demo program for working in graphics mode  (BIOS  INT 10h).'
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
	mov     dx,0                    ;  initial cursor position - 0, 0
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
	mov     Col,0                   ;  set initial color (black)
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
Exit:   mov     ah,0                    ;  function 0 - set video mode
	mov     al,VMODE                ;  AL - original mode
	int     10h                     ;  BIOS video service call
	mov     ax,4C00h                ;  Function 4Ch - terminate process
	int     21h                     ;  DOS service call
;-------------------------------------------------------------------
;
;  Output horizontal line
;
;-------------------------------------------------------------------
HORLINE PROC   NEAR
	xor     cx,cx                   ;  X - initial column for output
HOR1:   mov     ah,0Ch                  ;  function 0Ch - output pixel
	mov     al,Col                  ;  pixel color (bright red)
	mov     dx,Nstr                 ;  Y - row for output
	mov     bh,0                    ;  video page 0
	int     10h                     ;  BIOS video service call
	inc     cx                      ;  to next pixel
	cmp     cx,H_Leng               ;  end of line?
	jl      HOR1                    ;  not - continue output
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
VLIN3:  mov     ah,0Ch                  ;  function 0Ch - output pixel
	mov     al,Col                  ;  pixel color
	mov     bh,0                    ;  video page 0
	int     10h                     ;  BIOS video service call
	inc     dx                      ;  addres of low pixel
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
	END
