;-----------------------------------------------------------
;
;  File:   VESA.ASM
;
;  Desc:   Various functions for dealing with VESA std
;
;-----------------------------------------------------------

.model large

; argument addressing - 16-bit far calls

arg1  equ  [bp+6]
arg2  equ  [bp+8]
arg3  equ  [bp+10]
arg4  equ  [bp+12]

public _is_vesa

.data

vesa_name  db  'VESA'
name_size  equ 4
blk_size   equ 256

.code

;-----------------------------------------------------------
;  Desc:  determine if VESA compatible board is present
;  Use:   int is_vesa( void );
;  Ret:   1 -> VESA compatiblity, 0 -> none
;-----------------------------------------------------------

_is_vesa proc far
       push  bp
       mov   bp, sp

       push  es
       push  si
       push  di
       push  bx
       push  cx

       ; alloc space for info block
       sub   sp, blk_size

       ; point es:di to info block
       mov  ax, ss
       mov  es, ax
       mov  di, sp

       ; request info
       mov  ax, 4F00h
       int  10h
       cmp  ax, 4Fh
       jnz  is_vesa_1

;      ; verify presence of 'VESA' string
;      mov  ax, ss
;      mov  es, ax
;      mov  di, sp
;      mov  si, offset DGROUP:vesa_name
;      mov  cx, name_size
;      cld
;      repz cmpsb
;      or   cx, cx
;      jnz  is_vesa_1
;
;      ; vesa found
;      mov  ax, 1
       jmp short is_vesa_2

    is_vesa_1:
       ; vesa not found
       xor  ax, ax

    is_vesa_2:
       ; dealloc space for info block
       add   sp, blk_size

       pop   cx
       pop   bx
       pop   di
       pop   si
       pop   es

       pop   bp
       ret
_is_vesa endp

end
