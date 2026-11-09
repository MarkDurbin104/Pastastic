;-----------------------------------------------------------
;
;  File:   SETBINIO.ASM
;
;  Desc:   Function to force binary mode on a file
;          under MS-DOS
;
;-----------------------------------------------------------

.model large

; argument addressing - 16-bit far calls

arg1  equ  [bp+6]

public _setbinary

.code

;-----------------------------------------------------------
;  Desc:  Force binary mode on file
;  Use:   void setbinary( int handle );
;  In:    Handle of an open file.
;-----------------------------------------------------------

_setbinary proc far
     push  bp
     mov   bp, sp
     push  bx

     ; get device info
     mov  bx, arg1
     xor  ax, ax
     xor  dx, dx
     mov  ah, 44h
     int  21h

     ; high bit set if char device
     and  dl, 80h
     jz   setbinary_1

     ; set binary mode
     mov  bx, arg1
     xor  dh, dh
     or   dl, 20h
     mov  ah, 44h
     mov  al, 01h
     int  21h

   setbinary_1:
     pop   bx
     pop   bp
     ret
_setbinary endp

end
