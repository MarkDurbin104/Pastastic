;
;       Program OutVidD ( Chapter 8 )
;
.model small
.stack
.data
OutStr  db      80 dup ('þ',71h)
.code
.startup
	mov     ax,0B800h               ; address of video buffer
	mov     es,ax                   ; ES points to video buffer
	mov     di,160                  ; ES:DI - effective address of buffer
	lea     si,OutStr
	mov     cx,160
rep     movsb
.exit
	end             
