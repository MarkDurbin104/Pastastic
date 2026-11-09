;
;       Program OutVidB ( Chapter 8 )
;
.model small
.stack
.data
.code
.startup
	mov     ah,09h                  ; function 09h - output char+attr
	mov     bh,0                    ; video page 0 is used
	mov     al,254                  ; character to be output
	mov     bl,71h                  ; attribute to be output
	mov     cx,80                   ; repeat 80 times (one line)
	int     10h                     ; BIOS video service
.exit
	end             
