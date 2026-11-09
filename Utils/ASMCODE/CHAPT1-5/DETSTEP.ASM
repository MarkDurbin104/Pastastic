;
;       Program DetStep ( Chapter 2 )
;
page 55,132
.model  small
.stack
.data
TitMsg  db      'The program for demonstration the Trap Flag''s work.',0Dh,0Ah
	db      0Dh,0Ah,'$'
NotSet  db      'Cannot set the Trap Flag - the program works under debugger.'
	db      0Dh,0Ah,'$'
IsSet   db      'The trap flag is set successfully. No debugger active found.'
	db      0Dh,0Ah,'$'
.code
.startup
	lea     dx,TitMsg               ; address of initial message 
	mov     ah,09                   ; function 09 - output text string
	int     21h                     ; DOS service call
	pushf                           ; push original flags
	pop     ax                      ; copy original flag into AX
	or      ax,0100h                ; set bit 8 - Trap Flag
	push    ax                      ; push flags value to be set
	popf                            ; pop flags with TF set
	pushf                           ; push new flags value
	pop     ax                      ; copy new flags into AX
	and     ax,0100h                ; separate bit 8 - highlight TF
	lea     dx,IsSet                ; address of message "TF is set" 
	cmp     ax,0                    ; is bit 8 clear?
	jne     OutMsg                  ; if not, output message
	lea     dx,NotSet               ; address of message "cannot set TF"
OutMsg: mov     ah,09                   ; function 09 - output text string
	int     21h                     ; DOS service call
	pushf                           ; push original flags
	pop     ax                      ; copy original flag into AX
	and     ax,not 0100h            ; clear bit 8 - Trap Flag
	push    ax                      ; push flags value to be set
	popf                            ; pop flags with TF clear       
	mov     ax,4C00h                ; function 4Ch - terminate process
	int     21h                     ; DOS service call
	end
