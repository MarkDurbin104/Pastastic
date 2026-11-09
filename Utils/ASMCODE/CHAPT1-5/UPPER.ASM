;
;       Program Upper
;
page 55,132
.model  tiny
.stack  1024
.data
.code
.startup
;===    
	mov     si,81h                  ; starting address of parameter string
	mov     ah,02h                  ; function 02h - output character
	.WHILE (byte ptr [si] != 0Dh)   
	lodsb                           ; take next character into AL
	.IF al < 'a'
	.ELSEIF al > 'z'
	.ELSE
		and     al,0DFh         ; convert to uppercase
	.ENDIF
	mov     dl,al                   ; copy converted character for DOS service
	int     21h                     ; DOS service call
	.ENDW
.exit   0       
	end
