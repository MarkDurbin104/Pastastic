;
;       Program GetDay ( Chapter 6 )
;
.model  tiny
.code
	org     100h
Beg:    mov     ah,2Ah          ; function 2Ah - get current date
	int     21h             ; DOS service call
	
	mov     ah,4Ch          ; function 4Ch - terminate process
	mov     al,dl           ; return code is equal to day number
	int     21h             ; DOS service call
	
	end     Beg
