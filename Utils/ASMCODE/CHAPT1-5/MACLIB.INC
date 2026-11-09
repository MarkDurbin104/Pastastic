.XLIST
;       M A C R O   D E F I N I T I O N
;       อออออออออออออออออออออออออออออออ
;
;       Program MacLib.INC ( Chapter 5 )_
;
InpInt  macro   Dest
	local   Read , ExitMac , Number
;       if      <Dest> ne 'ax'
;               push    ax
;       endif
	push    cx
	push    bx
	mov     bx,0
	mov     cx,0
;       push    dx
	mov     Dest,0
Read:
	mov     ah,1            ; Prepare Dos Service Call - function 1
	int     21h             ; Dos Service 01 - get symbol with echo
	mov     dl,al           ; Save symbol to proceeding
;
;       Check if symbol is a number 0 ... 9
;
	cmp     al,'0'          ; Compare symbol in AL and ASCII code "0"
	jl      ExitMac         ; If symbol is less than "0" it is no number
	cmp     al,'9'          ; Compare symbol in AL and ASCII code "9"
	jg      ExitMac         ; If symbol is greater than "9" it is no number
				;===  Leave macro
Number:                         ;
	mov     ah,0
	sub     al,48           ; Convert symbol in AL into number
	mov     cx,ax           ; Save this number into CL
	mov     ax,10           ; Prepare to computing result
;       mul     bl              ; AL = BL * 10
;       add     al,cl           ; AL = ( BL * 10 )+ AL
	mul     bx              ; AX = BX * 10
	add     ax,cx           ; AX = ( BX * 10 )+ AX
	mov     bx,ax           ; Save the current result
				;
	jmp     Read            ; Read next symbol

ExitMac:
	mov     ax,bx           ; Save result into AX register
	pop     bx              ; Restore BX ( work register )
	pop     cx              ; Restore CX ( work register )
;       if      <Dest> ne 'ax'
		mov     Dest,ax ; Put result into target
;               pop     ax      ; Restore AX register
;       endif
	endm
				;
OutInt  macro   Src
	local   NexDiv,OutSym
	push    ax
	push    bx
	push    cx
	push    dx
	mov     ax,Src          ; Place number to be printed into AX.
;       mov     ah,0
	mov     bx,10           ; Place number '10'(divider) into DI.
	mov     cx,0
NexDiv:
	mov     dx,0
	div     bx              ; Divide command. After this result is in
				;    AL register and remainder in AH.
	push    dx              ; Push Remainder into stack.
;       mov     ah,0            ; Clear High byte of number to be divided.
	inc     cx              ; Increase counter
	cmp     ax,0            ; Check if result is zero and
	jne     NexDiv
	mov     ax,200h
OutSym: pop     dx
	add     dl,30h
	int     21h
	loop    OutSym
	pop     dx
	pop     cx
	pop     bx
	pop     ax
	endm
OutStr  macro   tpar
	local   locpar,aftcon   ; These label are internal
;;
;;      Attention! That's really wonderful!
;;      If you replace the name "locpar" with the
;;      name "par", MASM 5.0 will put the message
;;      "Error between phases".
;;
	push    ds              ; Save
	push    dx              ;      the
	push    ax              ;          registers
;
;       This locates parameter text in memory
;
	ifndef  par             ; Check wether parameter
				;   is present
	jmp     aftcon          ; Avoid to execute constants
locpar  db      tpar            ; Text string into memory
	db      0Dh, 0Ah        ; Line feed, carriage return
	db      '$'             ; This is needed for DOS
aftcon:
	endif
	mov     dx,cs
	mov     ds,dx
	mov     dx,offset cs:locpar
;
	mov     ah,9            ; Service 09 - put symbol
	int     21h             ; Dos service call
	pop     ax              ; Restore
	pop     dx              ;         the
	pop     ds              ;             registers
	endm
NewLine macro   Num
	push    ax
	push    dx
	mov     ah,02h
	mov     dx,0Dh
	int     21H
	mov     dx,0Ah
	int     21h
	pop     dx
	pop     ax
	endm
UpCase  macro   Letter
	local   UpCase,NotLet
	cmp     Letter,'a'
	jl      NotLet
	cmp     Letter,'z'
	jg      NotLet
UpCase: and     al,0DFh                 ; Force upper case
NotLet:
	endm
ToFlags macro   prm
	push    prm
	popf
	endm
GetFlags macro  prm
	pushf
	pop     prm
	endm

OutMsg  macro   txt
	local   MsgTxt,Work
	jmp     Work
MsgTxt  db      txt,'$'
Work:   push    ax
	push    dx
	push    ds
	push    cs
	pop     ds
	mov     dx,offset cs:MsgTxt
	mov     ah,09
	int     21h
	pop     ds
	pop     dx
	pop     ax
	endm

OutChar macro   CharForOutput
	push    ax
	push    dx
	mov     ah,02
	mov     dl,CharForOutput
	int     21h
	pop     dx
	pop     ax
	endm
	
OutBytes        macro   TextArr,LArray
	local   OutNext
	push    ax
	push    bx
	push    cx
	push    dx
	mov     bx,0
	mov     cx,LArray
	mov     ah,02
OutNext:mov     dl,TextArr[bx]
	int     21h
	inc     bx
	loop    OutNext 
	pop     dx
	pop     cx
	pop     bx
	pop     ax
	endm
.List
.sall
