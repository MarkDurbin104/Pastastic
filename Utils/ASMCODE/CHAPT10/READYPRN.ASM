;       Program ReadyPrn ( Chapter 10 )
;
	page    55,132
.model  tiny    
.stack
.data
.code
	org     100h
.startup        
	mov     ah,2            ; function 03h - get printer status byte
	mov     dx,0            ; DX=0 corresponds to LPT1 
	int     17h             ; BIOS printer service  
	mov     al,1            ; set return code to 1
	cmp     ah,80h          ; check bit 7 of status byte
	je      ExProg          ; if printer is OK - exit program
	mov     al,0            ; else set return code to 0
ExProg: mov     ah,4Ch          ; function 4Ch - exit program
	int     21h             ; DOS service call
	end
