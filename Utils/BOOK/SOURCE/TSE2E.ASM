;-----------------------------------------------------------
;
;  File:   TSE2E.ASM
;
;  Desc:   Functions to read and write scan lines in
;          mode 2Eh (640 x 480 x 256-colors) of the
;          Tseng ET4000 chip set
;
;-----------------------------------------------------------

.model large

; argument addressing - 16-bit far calls

arg1  equ  [bp+6]
arg2  equ  [bp+8]
arg3  equ  [bp+10]
arg4  equ  [bp+12]
arg5  equ  [bp+14]

; local variables

tmp1  equ  [bp-2]
ntmp  equ  2

public _put_pixels_2e, _get_pixels_2e

.code

;-----------------------------------------------------------
;  Desc:  Map extended video memory page
;  In:    CH = page number (0-4 for mode 2Eh)
;  Out:   nothing (all registers preserved)
;-----------------------------------------------------------

map_page proc near
     push ax
     push dx
     ; set "key" for seg-select register access
     mov  dx, 03BFh
     mov  al, 3
     out  dx, al
     mov  dx, 03D8h
     mov  al, 0A0h
     out  dx, al
     ; select segment - bits 0..3 of AL specifies
     ; write seg, bits 4..7 specifies read seg.
     mov  al, ch
     shl  al, 1
     shl  al, 1
     shl  al, 1
     shl  al, 1
     or   al, ch
     mov  dx, 03CDh
     out  dx, al
     pop  dx
     pop  ax
     ret
map_page endp

;-----------------------------------------------------------
;  Desc:  Compute page and offset of X,Y pixel coordinate
;  In:    BX = Y
;         CX = X
;  Out:   AX = Offset
;         CH = Page
;-----------------------------------------------------------

pxl_addr proc near
     mov  ax, 640   ; bytes per row
     mul  bx
     add  ax, cx    ; ax = offset
     adc  dx, 0     ; dl = page
     xor  cx, cx
     xchg ch, dl    ; ch = page
     ret
pxl_addr endp

;-----------------------------------------------------------
;  Desc:  Write scan line in Tseng 4000 mode 2Eh
;  Use:   void put_pixels_2e( unsigned char *pixels
;                             int npixels, int x, int y );
;-----------------------------------------------------------

_put_pixels_2e proc
     ; stack frame, save regs
     push bp
     mov  bp, sp
     sub  sp, ntmp
     push ds
     push es
     push di
     push si

     ; get page/offset, map page
     mov  bx, arg5
     mov  cx, arg4
     call pxl_addr
     mov  tmp1, cx     ; save page
     call map_page

     ; memory addressing
     mov  si, arg2
     mov  ds, si
     mov  si, arg1     ; ds:si -> pixel array
     mov  di, 0A000h
     mov  es, di
     mov  di, ax       ; es:di -> video buffer
     mov  cx, arg3     ; cx = pixel count

     ; does scan line cross page boundary?
     or   di, di       ; zero offset ?
     jz   put_pixels_2e_1
     mov  ax, 0FFFFh
     sub  ax, di
     inc  ax           ; ax = space in page
     cmp  ax, cx       ; room for cx pixels?
     jae  put_pixels_2e_1

     ; fill what's left of current page
     xchg ax, cx       ; cx = cnt in cur page
     sub  ax, cx       ; ax = cnt in next page
     cld
     rep  movsb
     mov  cx, tmp1     ; ch = cur page
     inc  ch           ; ch = next page
     call map_page
     xchg cx, ax       ; cx = pixel count

   put_pixels_2e_1:
     cld
     rep  movsb

     ; restore regs
     pop  si
     pop  di
     pop  es
     pop  ds
     add  sp, ntmp
     pop  bp
     ret
_put_pixels_2e endp

;-----------------------------------------------------------
;  Desc:  Read scan line in Tseng 4000 mode 2Eh
;  Use:   void get_pixels_2e( unsigned char *pixels
;                             int npixels, int x, int y );
;-----------------------------------------------------------

_get_pixels_2e proc
     ; stack frame, save regs
     push bp
     mov  bp, sp
     sub  sp, ntmp
     push ds
     push es
     push di
     push si

     ; get page/offset, map page
     mov  bx, arg5
     mov  cx, arg4
     call pxl_addr
     mov  tmp1, cx     ; save page
     call map_page

     ; memory addressing
     mov  di, arg2
     mov  es, di
     mov  di, arg1     ; es:di -> pixel array
     mov  si, 0A000h
     mov  ds, si
     mov  si, ax       ; ds:si -> video buffer
     mov  cx, arg3     ; cx = pixel count

     ; does scan line cross page boundary?
     or   si, si       ; zero offset ?
     jz   get_pixels_2e_1
     mov  ax, 0FFFFh
     sub  ax, si
     inc  ax           ; ax = space in page
     cmp  ax, cx       ; room for cx pixels?
     jae  get_pixels_2e_1

     ; fill what's left of current page
     xchg ax, cx       ; cx = cnt in cur page
     sub  ax, cx       ; ax = cnt in next page
     cld
     rep  movsb
     mov  cx, tmp1     ; ch = cur page
     inc  ch           ; ch = next page
     call map_page
     xchg cx, ax       ; cx = pixel count

   get_pixels_2e_1:
     cld
     rep  movsb

     ; restore regs
     pop  si
     pop  di
     pop  es
     pop  ds
     add  sp, ntmp
     pop  bp
     ret
_get_pixels_2e endp

end
