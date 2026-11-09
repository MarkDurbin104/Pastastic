;
;       Program ScanCodD ( Chapter 10 )
;
	page    55,132
.model  small
.stack
.data
CR      equ     00Dh            ; Carriage return code
LF      equ     00Ah            ; Line feed code
EscScan equ     001h            ; Scan code for ESC key
KbdPort equ     060h            ; PPI 9225 port A
EndMsg  equ     024h            ; Dollar sign - enf of message for DOS service
NewHand dd      NewInt9         ; Reference to the new handler for int 09
ScanCod db      0
BegMsg  db      CR,LF,LF
	db      '   SCAN CODES BROWSER 3.0 ', CR,CR,LF
	db      'Interrupt 09h handler totally replaced',CR,LF
	db      EndMsg
Kbd83   db      CR,LF,'You have a standard 83-key keyboard',CR,LF,EndMsg
Kbd101  db      CR,LF,'You have an enhanced 101/102 keyboard',CR,LF,EndMsg
InsMsg  db      CR,LF,'Press ESC to exit else',CR,LF
	db      'Press and relese any other key',CR,LF,LF,EndMsg
FinMsg  db      CR,LF,'       Job terminated',CR,LF
	db      ' Standard value of interrupt vector 09h '
	db      'has been restored.', CR,LF, EndMsg

.code
OutB    proc    near uses AX
	cmp     al,0Ah          ; Is it decimal digit ( 0 - 9)?
	jb      NoCorr          ; No correction - first 10 hex digit are dec
	cmp     al,10h          ; Is it hexadecimal digit ( A - F )?
	jb      HexCyph         ; If so correct for character representation
	mov     al,' '          ; If not, replace it with blank
	jmp     OutScr          ;   and output
HexCyph:add     al,07h          ; This transform hex digits A - F
NoCorr: add     al,30h          ; Convert integer to character
OutScr: mov     ah,0Eh          ; Function 0Eh - write character
	int     10h             ; BIOS video service
	inc     NumL
	cmp     NumL,60
	jl      NoNewL
	mov     al,CR
	int     10h
	mov     al,LF
	int     10h
	mov     NumL,0
NoNewL: ret
NumL    dw      0
OutB    endp

PrtByte proc    near uses AX DX
	mov     ah,0            ; Clear high part of AX
	mov     dx,0010h        ; Divider into BX
	div     dl              ; AL - result, AH - remainder
	mov     dx,ax           ; Save results
	call    OutB
	mov     al,dh
	call    OutB
	mov     al,' '          ; Character to be printed is a blank
	call    OutB
	ret                     ; Return to the caller
PrtByte endp

EndInt  proc    near
	in      al,61h          ; read Port B
	or      al,80h          ; set bit 7 to 1
	out     61h,al          ; output to port B
	jmp     $+2             ; delay (needed for fast PC)
	and     al, not 80h     ; clear bit 7
	out     61h,al          ; output to port B
	mov     al,20h          ; EOI code into AL
	out     20h,al          ; signal EOI
	ret
EndInt  endp    


NewInt9 proc    near
	mov     SaveAX,ax
ContKey:pushf                   ; save original flags
	in      al,60h          ; read scan code
	cmp     al,EscScan      ; ESC pressed?
	je      Fin             ; if so, return
	call    PrtByte         ; output scan code
	Call    EndInt
	sti                     ; allow interrupts
	popf                    ; restore original flags
	iret
Fin:    Call    EndInt
	mov     ax,SaveAX
	popf
Jmp9    db      0EAh            ; opcode for JMP FAR
OldInt9 dw      ?,?             ; Address of old handler for interrupt 09h
SaveAX  dw      ?       
NewInt9 endp

.startup
	lea     dx,BegMsg       ; Addres of start message into DX
	mov     ah,09           ; Function 09h - output text string
	int     21h             ; Dos service call

	mov     ax,40h          ; 40h - segment address for BIOS data area
	mov     es,ax           ; Place this address into ES
	test    byte ptr es:[96h],10h   ; Bit 4 - 101-key keyboard indicator
	jnz     Pres101
	lea     dx,Kbd83        ; Addres of start message into DX
	mov     ah,09           ; Function 09h - output text string
	int     21h             ; Dos service call
	jmp     PrtInstr

Pres101:
	lea     dx,Kbd101       ; Addres of start message into DX
	mov     ah,09           ; Function 09h - output text string
	int     21h             ; Dos service call

PrtInstr:
	lea     dx,InsMsg       ; Addres of start message into DX
	mov     ah,09           ; Function 09h - output text string
	int     21h             ; Dos service call

	mov     ah,35h          ; Function 35h - Get interrupt vector
	mov     al,09h          ; Interrupt number is 09h
	int     21h             ; DOS service call
	mov     OldInt9[0],bx         ; Save offset addres of old handler
	mov     OldInt9[2],es         ; Save segment address of old handler
	push    ds              ; DS will contain the segment of new handler
	lds     dx,NewHand      ; Full addres of new handler into DS:DX
	mov     ah,25h          ; Function 25h - set interrupt vector
	int     21h             ; DOS service call
	pop     ds              ; Restore the data segment register

NextKey:mov     ah,0Ch          ; Function 0Ch - clear the keyboard buffer
	int     21h             ; Dos service call
	mov     ah,0            ; Function 00h - read character from keyboard
	int     16h             ; BIOS keyboard service
	cmp     ah,EscScan      ; Is the ESC key pressed?
	jne     NextKey         ; If not - process the next key

Finis:  lea     dx,FinMsg       ; Addres of start message into DX
	mov     ah,09           ; Function 09h - output text string
	int     21h             ; Dos service call

	mov     dx,OldInt9[0]   ; Offset address for old handler into DX
	mov     ds,OldInt9[2]   ; Segment address for old handler into DS
	mov     ax,2509h        ; Set interrupt vector for INT 9
	int     21h             ; DOS service call
	
	mov     ax,4C00h        ; Function 4Ch - terminate process
	int     21h             ; DOS service call

	end
