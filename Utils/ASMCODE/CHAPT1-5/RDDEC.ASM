;
;       Program RdDec
;
.model  small                   ; small memory model - one segment only
.stack                          ; stack of default size
.data                           ; this starts data segment
UnsWord dw      0               ; number to be output
Ten     dw      10              ; constant for obtaining decimal digits
.code                           ; this starts code segments
.startup                        ; this initializes segment registers
NextCh: mov     ah,01           ; function 01h - keyboard input
	int     21h             ; DOS service call
	cmp     al,0            ; special character?
	jne     NotSpec         ; if not - process character
	int     21h             ; read code of special character
	jmp     FinProg         ; finish program
NotSpec:cmp     al,'0'          ; compare character read to "0" (number?)
	jb      FinProg         ; if not, don't process
	cmp     al,'9'          ; compare character read to "9" (number?)
	ja      FinProg         ; if not, don't process 
ProcNum:sub     al,30h          ; convert character to number
	mov     bl,al           ; copy character read into BX
	mov     ax,UnsWord      ; hex number into AX
	mul     Ten             ; one decimal position to the left
	mov     UnsWord,ax      ; store result back into memory
	add     UnsWord,bx      ; add current hex digit
	jmp     NextCh          ; read next character
FinProg:mov     ax,4C00h        ; function 4Ch - terminate process
	int     21h             ; DOS service call
	end     
