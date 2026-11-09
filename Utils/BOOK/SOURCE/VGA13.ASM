;-----------------------------------------------------------
;
;  File:   VGA13.ASM
;
;  Desc:   Functions to read and write scan lines in
;          VGA mode 13h (320 x 200 x 256-colors)
;
;-----------------------------------------------------------

.model large

; argument addressing - 16-bit far calls

arg1  equ  [bp+6]
arg2  equ  [bp+8]
arg3  equ  [bp+10]
arg4  equ  [bp+12]
arg5  equ  [bp+14]

public _put_pixels_13, _get_pixels_13

.code

;-----------------------------------------------------------
;  Desc:  Write scan line in VGA mode 13h
;  Use:   void put_pixels_13( unsigned char *pixels
;                             int npixels, int x, int y );
;-----------------------------------------------------------

_put_pixels_13 proc far
     ; stack frame, save regs
     push bp
     mov  bp, sp
     push ds
     push es
     push di
     push si

     ; source address
     mov  si, arg2
     mov  ds, si
     mov  si, arg1     ; ds:si -> pixel array

     ; destination address
     mov  di, 0A000h
     mov  es, di
     mov  ax, 320
     mov  bx, arg5
     mul  bx
     mov  di, arg4
     add  di, ax       ; es:di ->video buffer

     ; do block pixel move
     mov  cx, arg3     ; cx = pixel count
     rep  movsb

     ; restore regs
     pop  si
     pop  di
     pop  es
     pop  ds
     pop  bp
     ret
_put_pixels_13 endp

;-----------------------------------------------------------
;  Desc:  Read scan line in VGA mode 13h
;  Use:   void get_pixels_13( unsigned char *pixels
;                             int npixels, int x, int y );
;-----------------------------------------------------------

_get_pixels_13 proc far
     ; stack frame, save regs
     push bp
     mov  bp, sp
     push ds
     push es
     push di
     push si

     ; source address
     mov  si, 0A000h
     mov  ds, si
     mov  ax, 320
     mov  bx, arg5
     mul  bx
     mov  si, arg4
     add  si, ax       ; es:di ->video buffer

     ; destination address
     mov  di, arg2
     mov  es, di
     mov  di, arg1     ; ds:si -> pixel array

     ; do block pixel move
     mov  cx, arg3     ; cx = pixel count
     rep  movsb

     ; restore regs
     pop  si
     pop  di
     pop  es
     pop  ds
     pop  bp
     ret
_get_pixels_13 endp

end
