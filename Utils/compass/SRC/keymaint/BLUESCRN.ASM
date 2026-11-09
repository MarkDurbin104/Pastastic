code	segment	para	public	'code'
	assume	cs:code, ds:nothing, es:nothing, ss:nothing
	org	0100H
start	proc	near

	assume	cs:code, ds:code, es:code, ss:code
begin:
        mov     ax,0B800h       ; video base segment
        mov     es,ax           ;
        xor     di,di           ; begining of segment
        mov     cx,2000         ; number of words in screen (80 * 25)
        mov     ax,01F00h       ; attribute
        rep     stosw           ; fill screen

	mov	ax,4c00h        ; terminate program
	int	21h             ;

start	endp
code	ends
	end	start
