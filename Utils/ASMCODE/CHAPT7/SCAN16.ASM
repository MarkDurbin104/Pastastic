;
;       Program Scan16 ( Chapter 7 )
;
	page    55,132
.model  small
.stack
.data
CR      equ     00Dh            ; Carriage return code
LF      equ     00Ah            ; Line feed code
EscScan equ     001h            ; Scan code for ESC key
EndMsg  equ     024h            ; Dollar sign - enf of message for DOS service
BegMsg  db      CR,LF,LF
	db      '   SCAN CODES BROWSER 1.3 ' , CR , LF , EndMsg
Kbd83   db      CR,LF,'You have a standard 83-key keyboard',CR,LF,EndMsg
Kbd101  db      CR,LF,'You have an enhanced 101/102 keyboard',CR,LF,EndMsg
InsMsg  db      CR,LF,'Press ESC to exit else',CR,LF
	db      'Press and relese any other key',CR,LF,LF,EndMsg
FuncN   db      0
LinePos db      0
Con16   db      16
OutByte db      'xx ',EndMsg
CrLf    db      CR,LF,EndMsg
SymCod  db      0
HexTab  db      '0','1','2','3','4','5','6','7'
	db      '8','9','A','B','C','D','E','F'

.code

PrtByte proc near
	push    bx
	push    dx
	mov     ah,0                    ; AX now in range 0 - 255
	div     Con16                   ; AL - first hex digit, AH - second
	mov     bh,0                    ; Clear high part of BX
	mov     bl,al                   ; Take the first hex digit
	mov     al,HexTab[bx]           ; Take the corresponding character
	mov     OutByte[0],al           ; Place it into output string
	mov     bl,ah                   ; Take the second hex digit
	mov     al,HexTab[bx]           ; Take the corresponding character
	mov     OutByte[1],al           ; Place it into output string
	lea     dx,OutByte              ; Addres of scan code text into DX
	mov     ah,09                   ; Function 09h - output text string
	int     21h                     ; Dos service call
	pop     dx
	pop     bx
	ret
PrtByte endp

Begin:

	mov     ax,@data
	mov     ds,ax
	lea     dx,BegMsg               ; Addres of start message into DX
	mov     ah,09                   ; Function 09h - output text string
	int     21h                     ; Dos service call

	mov     ax,40h                  ; 40h - segment address for BIOS area
	mov     es,ax                   ; Place this address into ES
	mov     bh,es:[62h]             ; BH - Video page number
	test    byte ptr es:[96h],10h   ; Bit 4 - 101-key keyboard indicator
	jnz     Pres101                 ; If enhanced keyboard is present
	lea     dx,Kbd83                ; Addres of message into DX
	mov     ah,09                   ; Function 09h - output text string
	int     21h                     ; Dos service call
	jmp     PrtInstr

Pres101:
	mov     FuncN,10h               ; Enhanced input will be used
	lea     dx,Kbd101               ; Addres of start message into DX
	mov     ah,09                   ; Function 09h - output text string
	int     21h                     ; Dos service call

PrtInstr:
	lea     dx,InsMsg               ; Addres of message into DX
	mov     ah,09                   ; Function 09h - output text string
	int     21h                     ; Dos service call

NextKey:
	mov     ah,FuncN                ; Function 0h or 10h - read character
	int     16h                     ; BIOS keyboard service
	cmp     ah,EscScan              ; Is the ESC key pressed?
	je      Finis                   ; If it is so, finish the program
;       push    ax
	mov     SymCod,al               ; Store the ASCII code
	mov     al,ah                   ; Place the SCAN code into AL
	call    PrtByte                 ; Output the SCAN code
;       pop     ax
	mov     al,SymCod               ; Place the ASCII code into AL
	call    PrtByte                 ; Output the ASCII code
	mov     ah,0Ah                  ; Function 0Ah - Output character
	mov     al,SymCod               ; AL - character to be output
	mov     cx,1                    ; CX - counter of repeating output
	int     10h                     ; BIOS video service call
	mov     ah,09h                  ; Function 09h - Output text string
	lea     dx,CRLF                 ; DS:DX - addres of string to be output
	int     21h                     ; DOS service call
	jmp     NextKey                 ; Read next key

Finis:

	mov     ah,0Ch                  ; Function 0Ch - clear keyboard buffer
	int     21h                     ; Dos service call

	mov     ax,4C00h                ; Function 4Ch - terminate process
	int     21h                     ; DOS service call

	end     Begin
