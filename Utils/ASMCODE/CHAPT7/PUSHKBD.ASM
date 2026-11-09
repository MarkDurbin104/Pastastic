;
;       Program PushKbd ( Chapter 7 )
;
	page    55,132
.model  small
.stack
.code
PushCh  proc    near pascal uses ax cx, Scan:byte, ASCII:byte
	mov     ah,05                   ; Function 05h - Push scan/ASCII code
	mov     ch,Scan                 ; Scan code for char to be pushed
	mov     cl,ASCII                ; ASCII code for char to be pushed
	int     16h                     ; BIOS keyboard service
	ret                             ; return to caller
PushCh  endp
.startup
	invoke  PushCh,20h,'d'
	invoke  PushCh,17h,'i'  
	invoke  PushCh,13h,'r'  
	invoke  PushCh,1Ch,0Dh
	.exit
end
