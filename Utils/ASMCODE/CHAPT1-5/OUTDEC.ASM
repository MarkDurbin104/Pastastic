;
;       Program OutDec
;
.model  small                   ; small memory model - one segment only
.stack                          ; stack of default size
.data                           ; this starts data segment
UnsWord dw      1993            ; number to be output
Ten     dw      10              ; constant for obtaining decimal digits
.code                           ; this starts code segments
.startup                        ; this initializes segment registers
	mov     ax,UnsWord      ; place number to be printed into AX.
	mov     cx,0            ; clear counter of digits 
NexDiv: mov     dx,0            ; clear high part of number
	div     Ten             ; divide number to be prinred by 10
	push    dx              ; push remainder (current digit) into stack.
	inc     cx              ; increase counter of digits
	cmp     ax,0            ; result is zero? (number was less than 10)
	jne     NexDiv          ; if not, continue process (get next digit)
	mov     ax,0200h        ; function 02h - output character
OutSym: pop     dx              ; pop current digit from stack
	add     dl,30h          ; convert digit to character
	int     21h             ; DOS service call
	loop    OutSym          ; to output next digit
FinProg:mov     ax,4C00h        ; function 4Ch - terminate process (exit code 0)
	int     21h             ; DOS service call
	end     
